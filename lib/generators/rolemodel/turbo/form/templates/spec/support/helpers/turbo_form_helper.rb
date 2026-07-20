module TurboFormHelper
  def expect_turbo_form_request
    count_value = find("[data-controller='turbo-form']")['data-turbo-form-count-value'] || 0
    yield
    expect(page).to have_selector("[data-turbo-form-count-value='#{count_value.to_i + 1}']"),
                    'Expected a successful Turbo-Form request, but none was detected'
  end
end
