# frozen_string_literal: true

module SelectHelper
  include Capybara::DSL

  def smart_select(value, from:)
    label = find(:label, text: from, match: :first)
    input = find(id: label['for'], visible: :all)

    if input.tag_name == 'input' && input.native.attribute(:'aria-controls').include?('ts-dropdown')
      tom_select(input, value)
    elsif input.tag_name == 'tailored-select'
      tailored_select(input, value)
    else
      regular_select(value.to_s, from:)
    end
  end

  def tailored_select(input, value)
    option = input.find(:option, value, visible: :all)
    execute_script('arguments[0].click();', option)
  end

  def tom_select(input, value)
    input.ancestor('.ts-control').click
    input.send_keys(value)
    sleep 0.5 # required due to bug in tom-select
    input.send_keys(:enter)
  end

  alias regular_select select
  alias select smart_select
end
