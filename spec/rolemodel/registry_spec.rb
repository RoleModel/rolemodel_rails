# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'

RSpec.describe Rolemodel::Registry do
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

  def initializer_content
    File.read(initializer_path)
  end

  def recorded_keys
    initializer_content.scan(/g\.rolemodel (\w+):/).flatten
  end

  describe '.key_for' do
    it 'derives the key from the generator namespace with the rolemodel: prefix stripped' do
      expect(described_class.key_for(Rolemodel::WebpackGenerator)).to eq :webpack
    end

    it 'underscores nested namespaces' do
      expect(described_class.key_for(Rolemodel::Optics::BaseGenerator)).to eq :optics_base
    end

    it 'derives distinct keys for distinct AllGenerator classes' do
      expect(described_class.key_for(Rolemodel::AllGenerator)).to eq :all
      expect(described_class.key_for(Rolemodel::Optics::AllGenerator)).to eq :optics_all
    end
  end

  describe '.recorded?', :generator_config do
    it 'returns false (does not raise) when no rolemodel config exists' do
      expect(Rails::Generators.options[:rolemodel]).to be_nil
      expect(described_class.recorded?(:webpack)).to be false
    end

    it 'returns true for a key configured true' do
      apply_generator_config { |g| g.rolemodel webpack: true }

      expect(described_class.recorded?(:webpack)).to be true
    end

    it 'returns false for a key explicitly configured false' do
      apply_generator_config { |g| g.rolemodel webpack: false }

      expect(described_class.recorded?(:webpack)).to be false
    end

    it 'returns false for a key absent from the rolemodel namespace' do
      apply_generator_config { |g| g.rolemodel webpack: true }

      expect(described_class.recorded?(:sentry)).to be false
    end
  end

  describe '.record' do
    it 'creates the initializer with markers and one commented entry on first run' do
      result = described_class.record(:webpack, destination_root: destination_root)

      expect(result).to eq :recorded
      expect(initializer_content).to include(Rolemodel::Registry::BEGIN_MARKER)
      expect(initializer_content).to include(Rolemodel::Registry::END_MARKER)
      expect(initializer_content)
        .to include("g.rolemodel webpack: true # rolemodel_rails #{Rolemodel::VERSION}, #{Date.today.iso8601}")
    end

    it 'creates a file that is valid Ruby' do
      described_class.record(:webpack, destination_root: destination_root)

      expect { RubyVM::InstructionSequence.compile(initializer_content) }.not_to raise_error
    end

    it 'round-trips entries into config.generators, deep-merging into one namespace' do
      described_class.record(:webpack, destination_root: destination_root)
      described_class.record(:sentry, destination_root: destination_root)

      config = Rails::Configuration::Generators.new
      app_config = double('app config')
      allow(app_config).to receive(:generators) { |&block| block.call(config) }
      allow(Rails).to receive(:application).and_return(double('application', config: app_config))

      load initializer_path

      expect(config.options[:rolemodel]).to include(webpack: true, sentry: true)
    end

    it 'appends new entries alphabetically without disturbing existing ones' do
      described_class.record(:webpack, destination_root: destination_root, comment: 'first')
      described_class.record(:sentry, destination_root: destination_root)
      described_class.record(:optics_base, destination_root: destination_root)

      expect(recorded_keys).to eq %w[optics_base sentry webpack]
      expect(initializer_content).to include('g.rolemodel webpack: true # first')
    end

    it 're-recording refreshes the comment without duplicating the entry' do
      described_class.record(:webpack, destination_root: destination_root, comment: 'rolemodel_rails 1.0.0, 2020-01-01')
      result = described_class.record(:webpack, destination_root: destination_root,
                                                comment: 'rolemodel_rails 2.0.0, 2021-02-02')

      expect(result).to eq :recorded
      expect(initializer_content.scan(/g\.rolemodel webpack:/).length).to eq 1
      expect(initializer_content).to include('rolemodel_rails 2.0.0, 2021-02-02')
      expect(initializer_content).not_to include('1.0.0')
    end

    it 'never overwrites an explicit false entry' do
      described_class.record(:webpack, destination_root: destination_root)
      File.write(initializer_path, initializer_content.sub('webpack: true', 'webpack: false'))
      opted_out = initializer_content

      result = described_class.record(:webpack, destination_root: destination_root)

      expect(result).to eq :skipped_opt_out
      expect(initializer_content).to eq opted_out
    end

    it 'raises with recovery instructions when the file exists without markers' do
      FileUtils.mkdir_p(File.dirname(initializer_path))
      user_content = "# frozen_string_literal: true\n\n# hand-rolled file\n"
      File.write(initializer_path, user_content)

      expect { described_class.record(:webpack, destination_root: destination_root) }
        .to raise_error(Rolemodel::Registry::MissingMarkersError, /rolemodel:registry/)
      expect(initializer_content).to eq user_content
    end

    it 'leaves content outside the markers untouched' do
      described_class.record(:webpack, destination_root: destination_root)
      File.write(initializer_path, "# user note above the block\n#{initializer_content}# user note below\n")

      described_class.record(:sentry, destination_root: destination_root)

      expect(initializer_content).to start_with("# user note above the block\n")
      expect(initializer_content).to end_with("# user note below\n")
      expect(recorded_keys).to eq %w[sentry webpack]
    end
  end

  describe '.remove' do
    it 'removes the entry line and leaves the others' do
      described_class.record(:webpack, destination_root: destination_root)
      described_class.record(:sentry, destination_root: destination_root)

      result = described_class.remove(:webpack, destination_root: destination_root)

      expect(result).to eq :removed
      expect(recorded_keys).to eq %w[sentry]
      expect(initializer_content).to include(Rolemodel::Registry::BEGIN_MARKER)
    end

    it 'skips an explicit false entry' do
      described_class.record(:webpack, destination_root: destination_root)
      File.write(initializer_path, initializer_content.sub('webpack: true', 'webpack: false'))

      result = described_class.remove(:webpack, destination_root: destination_root)

      expect(result).to eq :skipped_opt_out
      expect(initializer_content).to include('g.rolemodel webpack: false')
    end

    it 'is a no-op when the file does not exist' do
      result = described_class.remove(:webpack, destination_root: destination_root)

      expect(result).to eq :not_recorded
      expect(File).not_to exist(initializer_path)
    end

    it 'is a no-op when the key is not recorded' do
      described_class.record(:webpack, destination_root: destination_root)

      expect(described_class.remove(:sentry, destination_root: destination_root)).to eq :not_recorded
      expect(recorded_keys).to eq %w[webpack]
    end
  end
end
