# frozen_string_literal: true

# SegmentedControlInput is a custom input type for SimpleForm that renders a radio group as an optics (v2.2.0+) segmented control
#
# Options:
#   :size (:small, :medium, :large) - renders the control at different sizes
#   :full_width - renders the control to take the full width of its container
#
# Usage:
# <%= f.input :my_field, as: :segmented_control, collection: collection_options %>
# <%= f.input :my_field, as: :segmented_control, collection: collection_options, size: :small %>
# <%= f.input :my_field, as: :segmented_control, collection: collection_options, disabled: true %>
# <%= f.input :my_field, as: :segmented_control, collection: collection_options, full_width: true %>
class SegmentedControlInput < SimpleForm::Inputs::CollectionRadioButtonsInput
  def input_type
    'radio_buttons'
  end

  def input_options
    options = super
    options[:item_wrapper_tag] = false
    options[:collection_wrapper_tag] = 'div'
    options[:collection_wrapper_class] = collection_wrapper_classes
    options[:item_label_class] = 'segmented-control__label'
    options
  end

  def input_html_options
    super.tap do |options|
      options[:class].delete('form-control')
    end
  end

  def input_html_classes
    super.push('segmented-control__input')
  end

  private

  def collection_wrapper_classes
    class_names(
      'segmented-control',
      options[:class],
      "segmented-control--#{options[:size]}": options[:size].present?,
      'segmented-control--full-width': options[:full_width].present?
    )
  end
end
