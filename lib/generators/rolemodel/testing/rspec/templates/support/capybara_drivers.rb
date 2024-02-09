# frozen_string_literal: true

RSpec.configure do |config|
  # Allow all tests to be run with :js or :chrome by using an environment variable
  if ENV['CAPYBARA_DRIVER'].present?
    config.define_derived_metadata do |metadata|
      metadata[ENV['CAPYBARA_DRIVER'].to_sym] = true
    end
  end

  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.before(:each, type: :system, js: true) do
    # Driver options define by Rails:
    #  driven_by :selenium, using: :chrome, screen_size: [1500, 1500]
    #  driven_by :selenium, using: :headless_chrome
    #  driven_by :selenium, using: :firefox
    #  driven_by :selenium, using: :headless_firefox
    driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400] do |driver_options|
      driver_options.add_preference(
        :download, directory_upgrade: true, prompt_for_download: false, default_directory: DownloadHelper::DOWNLOAD_PATH
      )
    end
  end

  config.before(:each, type: :system, chrome: true) do
    driven_by :selenium, using: :chrome do |driver_options|
      driver_options.add_preference(
        :download, directory_upgrade: true, prompt_for_download: false, default_directory: DownloadHelper::DOWNLOAD_PATH
      )
    end
  end

  config.before(:each, type: :system, firefox: true) do
    driven_by :selenium, using: :firefox
  end
end

# hide the annoying "Capybara starting Puma..." STDOUT message
Capybara.server = :puma, { Silent: true }
