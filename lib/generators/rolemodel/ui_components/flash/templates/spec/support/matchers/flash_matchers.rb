# frozen_string_literal: true

RSpec::Matchers.define :have_flash_content do |flash_message|
  match do |page|
    page.has_css?('.alert--flash', text: flash_message, visible: :all)
  end

  failure_message do
    "expected that page would have flash of #{flash_message} but was not found"
  end

  match_when_negated do |page|
    page.has_no_css?('.alert--flash', text: flash_message, visible: :all)
  end

  failure_message_when_negated do
    "expected that page would not have flash of #{flash_message} but was found"
  end
end
