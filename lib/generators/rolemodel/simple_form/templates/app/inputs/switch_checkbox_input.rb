# frozen_string_literal: true

# SwitchCheckboxInput is a custom input type for SimpleForm that renders a checkbox as a switch control
#
# Options:
#   :small - renders a smaller switch control
#   :label_after_input - renders the label after the switch control
#   :wrapper - the wrapper to use for this input, defaults to :inline_switch_wrapper. :switch_wrapper is also available.
#
# Usage:
# <%= f.input :my_field, as: :switch_checkbox %>
# <%= f.input :my_field, as: :switch_checkbox, small: true %>
# <%= f.input :my_field, as: :switch_checkbox, disabled: true %>
# <%= f.input :my_field, as: :switch_checkbox, label_after_input: true %>
# <%= f.input :my_field, as: :switch_checkbox, wrapper: :switch_wrapper %>
class SwitchCheckboxInput < SimpleForm::Inputs::BooleanInput
  def input(wrapper_options = nil)
    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)

    switch_group = template.content_tag(:div, class: "switch #{'switch--small' if options[:small]}") do
      if include_hidden?
        build_check_box(unchecked_value, merged_input_options)
      else
        build_check_box_without_hidden_field(merged_input_options)
      end +
      label(wrapper_options)
    end

    if options[:label_after_input]
      switch_group + label(wrapper_options)
    else
      label(wrapper_options) + switch_group
    end
  end

  def input_html_classes
    []
  end
end
