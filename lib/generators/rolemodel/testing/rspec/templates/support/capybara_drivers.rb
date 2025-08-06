RSpec.configure do |config|
  Capybara.register_driver :playwright_headless do |app|
    create_driver(app)
  end

  Capybara.register_driver :chrome do |app|
    create_driver(app, headless: false)
  end

  Capybara.register_driver :firefox do |app|
    create_driver(app, browser_type: :firefox)
  end

  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.before(:each, :js, type: :system) do
    driven_by :playwright_headless
  end

  config.before(:each, :chrome, type: :system) do
    driven_by :chrome
  end

  config.before(:each, :firefox, type: :system) do
    driven_by :firefox
  end

  def create_driver(app, options = {})
    default_options = {
      browser_type: :chromium,
      headless: true,
      viewport: { width: 1400, height: 1400 },
      browser_options: {
        args: ['--disable-backgrounding-occluded-windows']
      }
    }

    merged_options = default_options.merge(options)
    Capybara::Playwright::Driver.new(app, **merged_options)
  end
end

# hide the annoying "Capybara starting Puma..." STDOUT message
Capybara.server = :puma, { Silent: true }

# try to remove any potential for parallel tests to conflict
Capybara.threadsafe = true

Webdrivers.cache_time = 24.hours.to_i
