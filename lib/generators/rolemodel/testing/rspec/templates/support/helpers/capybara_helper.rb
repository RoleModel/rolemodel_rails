# frozen_string_literal: true

# Update the link_or_button selector so that we can use `click_on` with gc-menu-item
Capybara.modify_selector(:link_or_button) do
  label 'link or button'

  xpath do |locator, **options|
    %i[link button].map do |selector|
      expression_for(selector, locator, **options)
    end.reduce(:union)
  end
end

module LoadStateWaitingLogic
  module_function

  def add_wait_for_load_state(method_names)
    method_names.each do |method_name|
      define_method(method_name) do |*args, **kwargs, &block|
        super(*args, **kwargs, &block).tap do
          return unless CapybaraHelper.supports_javascript?

          Capybara.page.driver.with_playwright_page do |page|
            page.wait_for_load_state(state: 'networkidle')
          end
        end
      end
    end
  end
end

module LoadStateWaiter
  include LoadStateWaitingLogic

  INTERACTIVE_METHODS = %i[choose check uncheck select fill_in].freeze
  LoadStateWaitingLogic.add_wait_for_load_state(INTERACTIVE_METHODS)
end

module ElementLoadStateWaiter
  include LoadStateWaitingLogic

  INTERACTIVE_METHODS = %i[send_keys click select].freeze
  LoadStateWaitingLogic.add_wait_for_load_state(INTERACTIVE_METHODS)
end

Capybara::Node::Actions.prepend(LoadStateWaiter)
Capybara::Node::Element.prepend(ElementLoadStateWaiter)

module CapybaraHelper
  TIMEOUT = 10

  def resize_page(width, height)
    old_width, old_height = Capybara.page.current_window.size
    Capybara.page.current_window.resize_to(width, height)

    yield
  ensure
    Capybara.page.current_window.resize_to(old_width, old_height)
  end

  module_function

  def supports_javascript?
    Capybara.current_driver != :rack_test
  end

  def wait_until(timeout = TIMEOUT)
    Timeout.timeout(timeout) do
      sleep 0.1 until yield
    end
  end
end
