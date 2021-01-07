# frozen_string_literal: true

class BooleanInput < SimpleForm::Inputs::BooleanInput
  def input_html_classes
    super.push('form__checkbox')
  end
end
