# frozen_string_literal: true

class GroupedTomSelectInput < SimpleForm::Inputs::GroupedCollectionSelectInput
  def input(wrapper_options = nil)
    super(merge_wrapper_options(TomSelectInput.stimulus_options, wrapper_options))
  end

  def input_html_classes = []
end
