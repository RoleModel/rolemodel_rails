# frozen_string_literal: true

require 'spec_helper'

# Runtime trace of throwaway generator commands, so examples can assert
# whether the hook target actually ran.
COUPLING_HOOK_EVENTS = []

RSpec.describe 'Rolemodel::GeneratorBase.coupling_hook', :generator_config do
  after { COUPLING_HOOK_EVENTS.clear }

  # Runs a throwaway generator and returns everything it printed. The hosts
  # create no files and are marked skip_registry_entry!, so no destination
  # root is needed.
  def run_generator_class(klass, *args)
    output = StringIO.new
    original = $stdout
    $stdout = output
    klass.start(args)
    output.string
  ensure
    $stdout = original
  end

  it 'invokes the rolemodel:<hook_key> target after the actions when the other side is recorded' do
    apply_generator_config { |g| g.rolemodel other_side_probe: true }

    class Rolemodel::CouplingProbeGenerator < ::Rails::Generators::Base
      def record_target_run
        COUPLING_HOOK_EVENTS << :target
      end
    end

    class Rolemodel::CouplingHostGenerator < Rolemodel::GeneratorBase
      skip_registry_entry!

      def host_action
        COUPLING_HOOK_EVENTS << :action
      end

      coupling_hook :coupling_probe, with: :other_side_probe
    end

    output = run_generator_class(Rolemodel::CouplingHostGenerator)

    expect(COUPLING_HOOK_EVENTS).to eq %i[action target]
    expect(output).not_to include('Skipping coupling_probe')
  ensure
    remove_generators Rolemodel::CouplingProbeGenerator, Rolemodel::CouplingHostGenerator
  end

  it 'skips the hook and prints the re-run note when the other side is not recorded' do
    class Rolemodel::CouplingProbeGenerator < ::Rails::Generators::Base
      def record_target_run
        COUPLING_HOOK_EVENTS << :target
      end
    end

    class Rolemodel::CouplingHostGenerator < Rolemodel::GeneratorBase
      skip_registry_entry!

      def host_action
        COUPLING_HOOK_EVENTS << :action
      end

      coupling_hook :coupling_probe, with: :other_side_probe
    end

    output = run_generator_class(Rolemodel::CouplingHostGenerator)

    expect(COUPLING_HOOK_EVENTS).to eq %i[action]
    expect(output).to include(
      'Skipping coupling_probe — other_side_probe is not recorded in ' \
      'config/initializers/rolemodel_generators.rb. ' \
      'Re-run this generator after installing rolemodel:other_side_probe, ' \
      'or pass --coupling-probe.'
    )
  ensure
    remove_generators Rolemodel::CouplingProbeGenerator, Rolemodel::CouplingHostGenerator
  end

  it 'honors an explicit config opt-out even when the other side is recorded' do
    apply_generator_config { |g| g.rolemodel other_side_probe: true, coupling_probe: false }

    class Rolemodel::CouplingProbeGenerator < ::Rails::Generators::Base
      def record_target_run
        COUPLING_HOOK_EVENTS << :target
      end
    end

    class Rolemodel::CouplingHostGenerator < Rolemodel::GeneratorBase
      skip_registry_entry!

      def host_action
        COUPLING_HOOK_EVENTS << :action
      end

      coupling_hook :coupling_probe, with: :other_side_probe
    end

    output = run_generator_class(Rolemodel::CouplingHostGenerator)

    expect(COUPLING_HOOK_EVENTS).to eq %i[action]
    expect(output).to include('Skipping coupling_probe')
  ensure
    remove_generators Rolemodel::CouplingProbeGenerator, Rolemodel::CouplingHostGenerator
  end

  it 'fires the hook on an explicit --<hook-key> switch with an empty registry (AE1)' do
    class Rolemodel::CouplingProbeGenerator < ::Rails::Generators::Base
      def record_target_run
        COUPLING_HOOK_EVENTS << :target
      end
    end

    class Rolemodel::CouplingHostGenerator < Rolemodel::GeneratorBase
      skip_registry_entry!

      def host_action
        COUPLING_HOOK_EVENTS << :action
      end

      coupling_hook :coupling_probe, with: :other_side_probe
    end

    output = run_generator_class(Rolemodel::CouplingHostGenerator, '--coupling-probe')

    expect(COUPLING_HOOK_EVENTS).to eq %i[action target]
    expect(output).not_to include('Skipping coupling_probe')
  ensure
    remove_generators Rolemodel::CouplingProbeGenerator, Rolemodel::CouplingHostGenerator
  end

  it 'skips the hook on --no-<hook-key> even when the other side is recorded' do
    apply_generator_config { |g| g.rolemodel other_side_probe: true }

    class Rolemodel::CouplingProbeGenerator < ::Rails::Generators::Base
      def record_target_run
        COUPLING_HOOK_EVENTS << :target
      end
    end

    class Rolemodel::CouplingHostGenerator < Rolemodel::GeneratorBase
      skip_registry_entry!

      def host_action
        COUPLING_HOOK_EVENTS << :action
      end

      coupling_hook :coupling_probe, with: :other_side_probe
    end

    output = run_generator_class(Rolemodel::CouplingHostGenerator, '--no-coupling-probe')

    expect(COUPLING_HOOK_EVENTS).to eq %i[action]
    expect(output).to include('Skipping coupling_probe')
  ensure
    remove_generators Rolemodel::CouplingProbeGenerator, Rolemodel::CouplingHostGenerator
  end
end
