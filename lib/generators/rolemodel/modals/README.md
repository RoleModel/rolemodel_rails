# Modal and Panel Generator

## What you get

* Custom confirms
* Modal and panel styling
* Modal and panel view and link helper
* Modal and panel javascript

Adds UI and JavaScript for opening modals and the panel within a Rails view

## Example delete confirmation link
`= link_to "Test Confirm", delete_path(model), class: 'btn btn--primary', data: { confirm: 'Are you sure?', confirm_details: "This will delete #{model.name}. This action cannot be undone.", confirm_button: 'Yes, delete it' }`

The data attributes needed to make this work
- `confirm` (required) - Just like rails basic confirm functionality. This will be header text. E.g. "Are you sure?"
- `confirm_details` (optional, default: nil) - Provides additional details/text to the action the user about to take. E.g. "This will remove everything"
- `confirm_button` (optional, default: "Yes, I'm sure") - Allows the button text affirming the action to be changed

## Example Panel and Modal
Panel: `= panel_link_to 'Some link', panel_link_path, 'btn btn--primary'`
Modal: `= modal_link_to "Modal Test", new_model_path, 'btn btn--primary'`

For both the panel and the modal, you'll want to use the `full_screen` layout provided by the generator in your controller action. This allows the form/content to work if it is directly linked to in the browser rather than opened in a modal or panel

```ruby
class SomeController < ApplicationController
  def new
    render layout: 'full_screen'
  end
end
```
