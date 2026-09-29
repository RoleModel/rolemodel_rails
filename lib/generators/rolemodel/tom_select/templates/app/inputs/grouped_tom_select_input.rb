# frozen_string_literal: true

class GroupedTomSelectInput < SimpleForm::Inputs::GroupedCollectionSelectInput
  def input(wrapper_options = nil)
    super(merge_wrapper_options(tom_select_options, wrapper_options))
  end

  def input_html_classes = []

  private

  def tom_select_options
    { data: { controller: 'tom-select', action: TomSelectInput::MORPH_ACTIONS } }
  end
end
