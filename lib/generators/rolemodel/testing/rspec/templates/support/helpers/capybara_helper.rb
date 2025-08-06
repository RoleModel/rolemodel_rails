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
