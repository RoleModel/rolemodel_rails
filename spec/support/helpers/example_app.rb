module ExampleApp
  TEMPLATE_APP_PATH = File.expand_path('../../../example_rails8', __dir__)

  def prepare_test_app
    FileUtils.cp_r(TEMPLATE_APP_PATH, destination_root)
  end

  def run_generator_against_test_app(*args)
    FileUtils.cd(destination_root) { run_generator(*args) }
  end

  def cleanup_test_app
    FileUtils.rm_rf(destination_root)
  end
end
