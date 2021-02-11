# frozen_string_literal: true

class GroupedCollectionSelectInput < SimpleForm::Inputs::GroupedCollectionSelectInput
  def input_html_classes
    super.push('form__dropdown')
  end
end
