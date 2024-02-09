# frozen_string_literal: true

module CapybaraHelper
  def supports_javascript?
    RSpec.current_example.metadata[:js] || RSpec.current_example.metadata[:chrome]
  end
end
