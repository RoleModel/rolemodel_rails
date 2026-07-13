# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'

RSpec.describe Rolemodel::GeneratorBase, 'registry recording' do
  around do |example|
    Dir.mktmpdir do |dir|
      @destination_root = dir
      example.run
    end
  end

  attr_reader :destination_root

  def initializer_path
    File.expand_path(Rolemodel::Registry::INITIALIZER_PATH, destination_root)
  end

  def run_generator_class(klass, *args, behavior: :invoke)
    output = StringIO.new
    original = $stdout
    $stdout = output
    klass.start(args, destination_root: destination_root, behavior: behavior)
    output.string
  ensure
    $stdout = original
  end

  it 'does not register the invoke_all override as a Thor command' do
    # An unwrapped public invoke_all would become a command (it is not in
    # THOR_RESERVED_WORDS) and recurse on every generator run.
    expect(described_class.all_commands.keys).not_to include('invoke_all')
  end

  it 'records the derived key after a successful run and says so' do
    class Rolemodel::RecordingProbeGenerator < Rolemodel::GeneratorBase
      def leave_a_mark
        create_file 'probe.txt', "probe\n"
      end
    end

    output = run_generator_class(Rolemodel::RecordingProbeGenerator)

    expect(File.read(initializer_path))
      .to include("g.rolemodel recording_probe: true # rolemodel_rails #{Rolemodel::VERSION}")
    expect(output).to include('Recorded recording_probe')
  ensure
    remove_generators Rolemodel::RecordingProbeGenerator
  end

  it 'records nothing under --pretend' do
    class Rolemodel::RecordingProbeGenerator < Rolemodel::GeneratorBase
      def leave_a_mark
        create_file 'probe.txt', "probe\n"
      end
    end

    run_generator_class(Rolemodel::RecordingProbeGenerator, '--pretend')

    expect(File).not_to exist(initializer_path)
  ensure
    remove_generators Rolemodel::RecordingProbeGenerator
  end

  it 'removes the entry under rails destroy (behavior :revoke)' do
    Rolemodel::Registry.record(:recording_probe, destination_root: destination_root)
    Rolemodel::Registry.record(:webpack, destination_root: destination_root)

    class Rolemodel::RecordingProbeGenerator < Rolemodel::GeneratorBase
      def leave_a_mark
        create_file 'probe.txt', "probe\n"
      end
    end

    run_generator_class(Rolemodel::RecordingProbeGenerator, behavior: :revoke)

    expect(File.read(initializer_path)).not_to include('recording_probe')
    expect(File.read(initializer_path)).to include('g.rolemodel webpack: true')
  ensure
    remove_generators Rolemodel::RecordingProbeGenerator
  end

  it 'records nothing when an action raises mid-run' do
    class Rolemodel::ExplodingProbeGenerator < Rolemodel::GeneratorBase
      def explode
        raise 'boom'
      end
    end

    expect { run_generator_class(Rolemodel::ExplodingProbeGenerator) }.to raise_error('boom')
    expect(File).not_to exist(initializer_path)
  ensure
    remove_generators Rolemodel::ExplodingProbeGenerator
  end

  it 'records nothing for a generator marked skip_registry_entry!' do
    class Rolemodel::ExemptProbeGenerator < Rolemodel::GeneratorBase
      skip_registry_entry!

      def leave_a_mark
        create_file 'probe.txt', "probe\n"
      end
    end

    run_generator_class(Rolemodel::ExemptProbeGenerator)

    expect(File).not_to exist(initializer_path)
    expect(File).to exist(File.expand_path('probe.txt', destination_root))
  ensure
    remove_generators Rolemodel::ExemptProbeGenerator
  end

  it 'inherits skip_registry_entry? and defaults it to false' do
    class Rolemodel::ExemptProbeGenerator < Rolemodel::GeneratorBase
      skip_registry_entry!
    end

    class Rolemodel::ExemptChildProbeGenerator < Rolemodel::ExemptProbeGenerator; end

    expect(Rolemodel::GeneratorBase.skip_registry_entry?).to be false
    expect(Rolemodel::ExemptChildProbeGenerator.skip_registry_entry?).to be true
  ensure
    remove_generators Rolemodel::ExemptChildProbeGenerator, Rolemodel::ExemptProbeGenerator
  end

  it 'leaves an explicit false entry untouched and says why recording was skipped' do
    Rolemodel::Registry.record(:recording_probe, destination_root: destination_root)
    opted_out = File.read(initializer_path).sub('recording_probe: true', 'recording_probe: false')
    File.write(initializer_path, opted_out)

    class Rolemodel::RecordingProbeGenerator < Rolemodel::GeneratorBase
      def leave_a_mark
        create_file 'probe.txt', "probe\n"
      end
    end

    output = run_generator_class(Rolemodel::RecordingProbeGenerator)

    expect(File.read(initializer_path)).to eq opted_out
    expect(output).to include('Not recording recording_probe')
  ensure
    remove_generators Rolemodel::RecordingProbeGenerator
  end
end
