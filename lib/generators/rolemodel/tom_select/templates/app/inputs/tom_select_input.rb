# frozen_string_literal: true

class TomSelectInput < SimpleForm::Inputs::CollectionSelectInput
  def self.stimulus_options
    {
      data: {
        controller: 'tom-select',
        tom_select_target: 'dropdown',
        action: 'turbo:before-morph-element->tom-select#disconnect:self turbo:morph-element->tom-select#afterMorph:self'
      }
    }
  end

  def input(wrapper_options = nil)
    super(merge_wrapper_options(self.class.stimulus_options, wrapper_options))
  end

  def input_html_classes = []
end
