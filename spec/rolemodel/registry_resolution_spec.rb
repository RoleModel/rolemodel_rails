# frozen_string_literal: true

require 'spec_helper'
require 'open3'

# Executable verification of the framework mechanics the generator registry
# design rests on. Each example pins a fact about Rails' resolution chain;
# if one fails after a Rails upgrade, revisit the registry design before
# debugging anything built on top of it.
REGISTRY_RESOLUTION_ORDER = []

RSpec.describe 'Registry resolution chain', :generator_config do
  after { REGISTRY_RESOLUTION_ORDER.clear }

  describe 'config.generators -> Rails::Generators.options' do
    it 'routes g.rolemodel entries into the :rolemodel namespace' do
      apply_generator_config { |g| g.rolemodel registry_probe: true }

      expect(Rails::Generators.options[:rolemodel][:registry_probe]).to be true
    end
  end

  describe 'boolean hook_for default resolution at class definition' do
    it 'resolves the default from the rolemodel namespace' do
      apply_generator_config { |g| g.rolemodel registry_probe: true }

      class Rolemodel::ProbeAlphaGenerator < ::Rails::Generators::Base
        hook_for :registry_probe, type: :boolean
      end

      expect(Rolemodel::ProbeAlphaGenerator.class_options[:registry_probe].default).to be true
    ensure
      remove_generators Rolemodel::ProbeAlphaGenerator
    end

    it 'prefers generator_name config over base_name config' do
      apply_generator_config do |g|
        g.rolemodel registry_probe: true
        g.probe_beta registry_probe: false
      end

      class Rolemodel::ProbeBetaGenerator < ::Rails::Generators::Base
        hook_for :registry_probe, type: :boolean
      end

      expect(Rolemodel::ProbeBetaGenerator.class_options[:registry_probe].default).to be false
    ensure
      remove_generators Rolemodel::ProbeBetaGenerator
    end

    it 'falls back to the class default when no config exists (spec-harness condition)' do
      class Rolemodel::ProbeGammaGenerator < ::Rails::Generators::Base
        hook_for :registry_probe, type: :boolean
      end

      expect(Rolemodel::ProbeGammaGenerator.class_options[:registry_probe].default).to be_falsey
    ensure
      remove_generators Rolemodel::ProbeGammaGenerator
    end
  end

  describe 'boolean hook target lookup' do
    it 'resolves rolemodel:<hook_name> ahead of a bare <hook_name> generator' do
      class Rolemodel::RegistryProbeGenerator < ::Rails::Generators::Base; end
      class RegistryProbeGenerator < ::Rails::Generators::Base; end

      class Rolemodel::ProbeDeltaGenerator < ::Rails::Generators::Base
        hook_for :registry_probe, type: :boolean
      end

      resolved = Rolemodel::ProbeDeltaGenerator.prepare_for_invocation(:registry_probe, :registry_probe)
      expect(resolved).to eq Rolemodel::RegistryProbeGenerator
    ensure
      remove_generators Rolemodel::RegistryProbeGenerator, ::RegistryProbeGenerator,
                        Rolemodel::ProbeDeltaGenerator
    end
  end

  describe 'hook execution order' do
    it 'runs hook invocations at their declaration position, not before or after all actions' do
      apply_generator_config { |g| g.rolemodel registry_probe: true }

      class Rolemodel::RegistryProbeGenerator < ::Rails::Generators::Base
        def record_hook_ran
          REGISTRY_RESOLUTION_ORDER << :hook
        end
      end

      class Rolemodel::ProbeEpsilonGenerator < ::Rails::Generators::Base
        def first_step
          REGISTRY_RESOLUTION_ORDER << :first
        end

        hook_for :registry_probe, type: :boolean

        def last_step
          REGISTRY_RESOLUTION_ORDER << :last
        end
      end

      quietly { Rolemodel::ProbeEpsilonGenerator.start([]) }

      expect(REGISTRY_RESOLUTION_ORDER).to eq %i[first hook last]
    ensure
      remove_generators Rolemodel::RegistryProbeGenerator, Rolemodel::ProbeEpsilonGenerator
    end
  end

  describe 'engine eager-require path' do
    it 'defines no hook-declaring generators when all_generator is required' do
      root = File.expand_path('../..', __dir__)
      script = <<~RUBY
        require 'bundler/setup'
        require 'rails'
        require 'rails/generators'
        $LOAD_PATH.unshift File.expand_path('lib')
        require 'rolemodel-rails'
        require 'generators/rolemodel/all_generator'

        hooked = Rails::Generators.subclasses.select do |klass|
          klass.name.to_s.start_with?('Rolemodel') && klass.hooks.any?
        end
        if hooked.any?
          warn "hook-declaring generators on the eager-require path: \#{hooked.map(&:name).join(', ')}"
          exit 1
        end
      RUBY

      _out, err, status = Open3.capture3(RbConfig.ruby, '-e', script, chdir: root)

      # Classes loaded eagerly by the engine's generators block resolve their
      # hook defaults BEFORE Rails::Generators.configure! runs (verified against
      # railties 8.1.2 Rails::Engine#load_generators), so they would silently
      # ignore the registry. Coupling declarations belong on lazily-loaded leaf
      # generators only.
      expect(status).to be_success, err
    end
  end
end
