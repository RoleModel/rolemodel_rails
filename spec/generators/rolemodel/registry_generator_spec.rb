# frozen_string_literal: true

RSpec.describe Rolemodel::RegistryGenerator, type: :generator do
  include ExampleApp

  let(:initializer_path) { File.expand_path(Rolemodel::Registry::INITIALIZER_PATH, destination_root) }

  before { prepare_test_app }

  context 'with no existing registry file' do
    it 'creates the initializer and seeds detected generators' do
      expect(File.exist?(initializer_path)).to be(false)

      run_generator_against_test_app

      expect(File.exist?(initializer_path)).to be(true)
      content = File.read(initializer_path)
      expect(content).to include(Rolemodel::Registry::BEGIN_MARKER)
      expect(content).to include(Rolemodel::Registry::END_MARKER)

      # The example app has webpack config and a Procfile (from heroku setup)
      # so those should be detected
      expect(content).to include('seeded-by-detection')
    end
  end

  context 'with an existing registry file that has a genuine entry' do
    before do
      # Simulate a genuine registry entry with a version stamp
      FileUtils.mkdir_p(File.dirname(initializer_path))
      File.write(initializer_path, <<~RUBY)
        # frozen_string_literal: true

        Rails.application.config.generators do |g|
          #{Rolemodel::Registry::BEGIN_MARKER}
          g.rolemodel webpack: true # rolemodel_rails 1.0.0, 2026-01-01
          #{Rolemodel::Registry::END_MARKER}
        end
      RUBY
    end

    it 'never overwrites a genuine version-stamped entry' do
      run_generator_against_test_app

      content = File.read(initializer_path)
      # The existing webpack entry with its version stamp should be untouched
      expect(content).to include('g.rolemodel webpack: true # rolemodel_rails 1.0.0, 2026-01-01')
      # Other detected generators may be seeded alongside it
      expect(content).to include('seeded-by-detection')
    end
  end

  context 'with a seeded entry from a prior run' do
    before do
      FileUtils.mkdir_p(File.dirname(initializer_path))
      File.write(initializer_path, <<~RUBY)
        # frozen_string_literal: true

        Rails.application.config.generators do |g|
          #{Rolemodel::Registry::BEGIN_MARKER}
          g.rolemodel sentry: true # seeded-by-detection
          #{Rolemodel::Registry::END_MARKER}
        end
      RUBY
    end

    it 'overwrites its own seeded entries to keep the comment clean' do
      run_generator_against_test_app

      content = File.read(initializer_path)
      # Should still have sentry, but not duplicate it
      expect(content.scan(/g\.rolemodel sentry:/).length).to eq(1)
    end
  end

  context 'with an explicit opt-out entry' do
    before do
      FileUtils.mkdir_p(File.dirname(initializer_path))
      File.write(initializer_path, <<~RUBY)
        # frozen_string_literal: true

        Rails.application.config.generators do |g|
          #{Rolemodel::Registry::BEGIN_MARKER}
          g.rolemodel webpack: false
          #{Rolemodel::Registry::END_MARKER}
        end
      RUBY
    end

    it 'never overwrites a false (opt-out) entry' do
      run_generator_against_test_app

      content = File.read(initializer_path)
      expect(content).to include('g.rolemodel webpack: false')
      # The false entry should still be there, not replaced with true
      expect(content).not_to include('g.rolemodel webpack: true')
    end
  end

  context 're-running on the same app' do
    before do
      # First run
      run_generator_against_test_app
    end

    it 'is a no-op that reports current state' do
      first_run_content = File.read(initializer_path)

      run_generator_against_test_app

      second_run_content = File.read(initializer_path)

      # Content should not change on re-run
      expect(second_run_content).to eq(first_run_content)
    end
  end

  context 'exemption from registry recording' do
    it 'is exempt from registry recording (it is a composite/bootstrap generator)' do
      expect(described_class.skip_registry_entry?).to be(true)
    end
  end
end
