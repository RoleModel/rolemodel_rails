RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.before(:each, type: :system, js: true) do
    # Driver options define by Rails:
    #  driven_by :selenium, using: :chrome, screen_size: [1500, 1500]
    #  driven_by :selenium, using: :headless_chrome
    #  driven_by :selenium, using: :firefox
    #  driven_by :selenium, using: :headless_firefox
    driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]
  end

  config.before(:each, type: :system, chrome: true) do
    driven_by :selenium, using: :chrome
  end

  config.before(:each, type: :system, firefox: true) do
    driven_by :selenium, using: :firefox
  end
end

# hide the annoying "Capybara starting Puma..." STDOUT message
Capybara.server = :puma, { Silent: true }
Webdrivers.cache_time = 24.hours.to_i
