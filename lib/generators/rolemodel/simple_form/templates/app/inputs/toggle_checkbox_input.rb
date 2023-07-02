# frozen_string_literal: true

# ToggleCheckboxInput is a custom input type for SimpleForm that renders a checkbox as a toggle control
#
# Options:
#   :small - renders a smaller toggle control
#   :label_after_input - renders the label after the toggle control
#   :wrapper - the wrapper to use for this input, defaults to :inline_toggle_wrapper. :toggle_wrapper is also available.
#
# Usage:
# <%= f.input :my_field, as: :toggle_checkbox %>
# <%= f.input :my_field, as: :toggle_checkbox, small: true %>
# <%= f.input :my_field, as: :toggle_checkbox, label_after_input: true %>
# <%= f.input :my_field, as: :toggle_checkbox, wrapper: :toggle_wrapper %>
class ToggleCheckboxInput < SimpleForm::Inputs::BooleanInput
  def input(wrapper_options = nil)
    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)

    toggle_group = template.content_tag(:div, class: "toggle #{'toggle--small' if options[:small]}") do
      build_check_box_without_hidden_field(merged_input_options) +
        label(wrapper_options)
    end

    if options[:label_after_input]
      toggle_group + label(wrapper_options)
    else
      label(wrapper_options) + toggle_group
    end
  end

  def input_html_classes
    []
  end
end
