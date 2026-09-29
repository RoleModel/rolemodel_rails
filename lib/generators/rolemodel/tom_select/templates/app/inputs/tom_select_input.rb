# frozen_string_literal: true

class TomSelectInput < SimpleForm::Inputs::CollectionSelectInput
  MORPH_ACTIONS = 'turbo:before-morph-element->tom-select#disconnect:self turbo:morph-element->tom-select#afterMorph:self'

  def input(wrapper_options = nil)
    super(merge_wrapper_options(tom_select_options, wrapper_options))
  end

  def input_html_classes = []

  private

  def tom_select_options
    { data: { controller: 'tom-select', tom_select_create_value: options.delete(:allow_create) || false, action: MORPH_ACTIONS } }
  end
end
