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

    pw_page.locator('body').evaluate 'element => element.classList.add("full-page-screenshot")' if options[:fullPage]

    pw_page.screenshot(path: "#{directory}/#{filename}.png", animations: 'disabled', **options)

    puts "Screenshot saved to \e[4;96m#{directory}/#{filename}.png\e[0m" if print_message
  end

  def self.scope_stack
    @scope_stack ||= []
  end

  def current_scope
    PlaywrightHelper.scope_stack.last || pw_page
  end

  def within(selector, **, &block)
    if supports_javascript?
      begin
        pw_locator = if selector.is_a?(Capybara::Node::Element)
                       pw_page.locator("xpath=#{selector.path}")
                     else
                       pw_page.locator(selector)
                     end

        PlaywrightHelper.scope_stack.push(pw_locator)

        super
      ensure
        PlaywrightHelper.scope_stack.pop
      end
    else
      super
    end
  end

  def click_on(text = nil, **args)
    if supports_javascript? && text.present?
      scope = current_scope
      locator = nil

      %w[button link gc-menu-item summary].each do |tag|
        loc = scope.get_by_role(tag).get_by_text(text)
        loc = scope.get_by_role(tag).get_by_text(text, exact: true) if loc.count > 1
        loc = scope.locator(tag).get_by_text(text) unless loc.count == 1
        locator = loc if loc.count == 1
        break if locator.present?
      end

      locator = scope.get_by_text(text, exact: true) if locator.blank?

      raise "No element matching text: '#{text}'" if locator.count < 1

      if locator.count > 1
        raise "Multiple elements matching text: '#{text}'" unless args[:match] == :first

        result = locator.first.click
      else
        result = locator.click
      end

      pw_page.wait_for_load_state(state: 'networkidle')
      result
    else
      Capybara.click_on(text, **args)
    end
  end
end
