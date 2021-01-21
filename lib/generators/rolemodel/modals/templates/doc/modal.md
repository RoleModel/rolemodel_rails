# Modals

## Example modal link
`= modal_link_to("Modal Test", new_model_path)`

## Example delete confirmation link
`= link_to "Test Confirm", model_path(model), class: 'btn btn--primary', data: { custom_confirm: true, confirm_title: 'Are you sure?', confirm_body: "This will delete #{model.name}. This action cannot be undone.", confirm_form_method: :delete }`
