module ExampleApp
  TEMPLATE_APP_PATH = File.expand_path('../../../example_rails7', __dir__)

  def prepare_test_app
    FileUtils.cp_r(TEMPLATE_APP_PATH, destination_root)
  end

  def cleanup_test_app
    FileUtils.rm_rf(destination_root)
  end
end
