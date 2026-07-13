# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'

RSpec.describe 'Rolemodel::GeneratorBase.requires_generator', :generator_config do
  around do |example|
    Dir.mktmpdir do |dir|
      @destination_root = dir
      example.run
    end
  end

  attr_reader :destination_root

  # Thor::Base.start rescues Thor::Error (prints it and exits non-zero), so
  # examples asserting on the raised error drive the generator through
  # invoke_all — the same entry point start uses underneath.
  def build_generator(klass, behavior: :invoke)
    klass.new([], {}, destination_root: destination_root, behavior: behavior)
  end

  def probe_file
    File.expand_path('probe.txt', destination_root)
  end

  it 'raises Thor::Error before any action runs when the key is not recorded' do
    class Rolemodel::GuardedProbeGenerator < Rolemodel::GeneratorBase
      skip_registry_entry!
      requires_generator :prerequisite_probe

      def leave_a_mark
        create_file 'probe.txt', "probe\n"
      end
    end

    expect { build_generator(Rolemodel::GuardedProbeGenerator).invoke_all }
      .to raise_error(Thor::Error, /prerequisite_probe/)
    expect(File).not_to exist(probe_file)
  ensure
    remove_generators Rolemodel::GuardedProbeGenerator
  end

  it 'names the missing generator and the seeder in the abort message' do
    class Rolemodel::GuardedProbeGenerator < Rolemodel::GeneratorBase
      skip_registry_entry!
      requires_generator :prerequisite_probe
    end

    expect { build_generator(Rolemodel::GuardedProbeGenerator).invoke_all }
      .to raise_error(Thor::Error) do |error|
        expect(error.message).to include('bin/rails generate rolemodel:prerequisite_probe')
        expect(error.message).to include('bin/rails generate rolemodel:registry')
      end
  ensure
    remove_generators Rolemodel::GuardedProbeGenerator
  end

  it 'aborts a start-driven run with the message on stderr and no files created' do
    # Thor::Base.start rescues Thor::Error and reports it through the shell;
    # Rails::Generators::Base.exit_on_failure? is false (railties 8.1.2), so
    # no SystemExit is raised here — bin/rails handles the exit status.
    class Rolemodel::GuardedProbeGenerator < Rolemodel::GeneratorBase
      skip_registry_entry!
      requires_generator :prerequisite_probe

      def leave_a_mark
        create_file 'probe.txt', "probe\n"
      end
    end

    expect { Rolemodel::GuardedProbeGenerator.start([], destination_root: destination_root) }
      .to output(/prerequisite_probe/).to_stderr
    expect(File).not_to exist(probe_file)
  ensure
    remove_generators Rolemodel::GuardedProbeGenerator
  end

  it 'proceeds when the key is recorded' do
    apply_generator_config { |g| g.rolemodel prerequisite_probe: true }

    class Rolemodel::GuardedProbeGenerator < Rolemodel::GeneratorBase
      skip_registry_entry!
      requires_generator :prerequisite_probe

      def leave_a_mark
        create_file 'probe.txt', "probe\n"
      end
    end

    quietly { build_generator(Rolemodel::GuardedProbeGenerator).invoke_all }

    expect(File).to exist(probe_file)
  ensure
    remove_generators Rolemodel::GuardedProbeGenerator
  end

  it 'no-ops for a generator with no declarations' do
    class Rolemodel::UnguardedProbeGenerator < Rolemodel::GeneratorBase
      skip_registry_entry!

      def leave_a_mark
        create_file 'probe.txt', "probe\n"
      end
    end

    quietly { build_generator(Rolemodel::UnguardedProbeGenerator).invoke_all }

    expect(File).to exist(probe_file)
  ensure
    remove_generators Rolemodel::UnguardedProbeGenerator
  end

  it 'never blocks rails destroy: an unmet prerequisite proceeds under behavior :revoke' do
    class Rolemodel::GuardedProbeGenerator < Rolemodel::GeneratorBase
      skip_registry_entry!
      requires_generator :prerequisite_probe

      def leave_a_mark
        create_file 'probe.txt', "probe\n"
      end
    end

    expect { quietly { build_generator(Rolemodel::GuardedProbeGenerator, behavior: :revoke).invoke_all } }
      .not_to raise_error
  ensure
    remove_generators Rolemodel::GuardedProbeGenerator
  end

  it 'accumulates keys down the inheritance chain without polluting ancestors' do
    class Rolemodel::GuardedParentGenerator < Rolemodel::GeneratorBase
      requires_generator :alpha_probe
    end

    class Rolemodel::GuardedChildGenerator < Rolemodel::GuardedParentGenerator
      requires_generator :beta_probe
    end

    expect(Rolemodel::GuardedChildGenerator.required_generator_keys).to eq %i[alpha_probe beta_probe]
    expect(Rolemodel::GuardedParentGenerator.required_generator_keys).to eq %i[alpha_probe]
    expect(Rolemodel::GeneratorBase.required_generator_keys).to eq []
  ensure
    remove_generators Rolemodel::GuardedChildGenerator, Rolemodel::GuardedParentGenerator
  end
end
