# frozen_string_literal: true

module ExampleApp
  TEMPLATE_APP_PATH = File.expand_path Dir.glob('./example_rails?').max # Always test against the most recent example app

  def prepare_test_app
    self.destination_root ||= File.expand_path('spec/tmp')
    cleanup_test_app
    FileUtils.cp_r(TEMPLATE_APP_PATH, destination_root)
    clean_test_gemfile
  end

  # run_generator already captures stdout
  # capturing stderr does not prevent tests from failing,
  # but does keep the test output clean and easy to read
  def run_generator_against_test_app(*args, generator: described_class)
    self.generator_class = generator
    capture(:stderr) do
      FileUtils.cd(destination_root) { run_generator(*args) }
    end
  end

  def cleanup_test_app
    FileUtils.rm_rf(destination_root)
  end

  def clean_test_gemfile
    gemfile_path = File.join(destination_root, 'Gemfile')
    gemfile = File.open(gemfile_path)

    File.write(gemfile_path, gemfile.grep_v(/rolemodel_rails/).join)
  end
end
