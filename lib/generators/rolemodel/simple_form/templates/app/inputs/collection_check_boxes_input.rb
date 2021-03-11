# frozen_string_literal: true

class CollectionCheckBoxesInput < SimpleForm::Inputs::CollectionCheckBoxesInput
  def item_wrapper_class
    'form__group--checkbox'
  end
end
