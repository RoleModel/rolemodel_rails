# frozen_string_literal: true

module PlaywrightHelper
  # Use Playwright's page object
  def pw_page
    page.driver.with_playwright_page do |page|
      return page
    end
  end

  # Helper method for taking screenshots in system tests
  def screenshot(filename = nil, directory: 'tmp/screenshots', print_message: true, **options)
    timestamp = Time.current.strftime('%Y-%m-%d_%H-%M-%S')
    description = RSpec.current_example.full_description.tr(' ', '_')
    filename ||= "#{description}_#{timestamp}"

    FileUtils.mkdir_p(directory)

    pw_page.locator('body').evaluate("element => element.style.overflow = 'visible'") if options[:fullPage]

    pw_page.screenshot(path: "#{directory}/#{filename}.png", animations: 'disabled', **options)

    puts "Screenshot saved to \e[4;96m#{directory}/#{filename}.png\e[0m" if print_message
  end
end
