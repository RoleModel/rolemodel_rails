# frozen_string_literal: true

class CollectionSelectInput < SimpleForm::Inputs::CollectionSelectInput
  def input_html_classes
    super.push('form__dropdown')
  end
end
