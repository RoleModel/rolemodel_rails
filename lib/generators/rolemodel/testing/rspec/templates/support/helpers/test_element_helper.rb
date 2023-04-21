module TestElementHelper
  include ActionView::RecordIdentifier

  def data_test(name)
    if name.respond_to?(:id)
      "[data-testid='#{dom_id(name)}']"
    else
      "[data-testid='#{name}']"
    end
  end
end
