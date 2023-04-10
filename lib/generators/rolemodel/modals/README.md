# Modal and Panel Generator

## What you get

* Custom confirm dialogs via `@rolemodel/turbo-confirm` integration
* Modal and panel styling ..via `@rolemodel/optics` integration?
* Modal and panel layouts w/ link helpers (or you could just, e.g. `link_to ... data: {turbo_frame: 'modal'}`)
* frame-missing handler (required for turbo-rails v1.4.0 and above)

Adds UI and JavaScript for opening modals and the panel within a Rails view

## Example delete confirmation link
`= link_to "Test Confirm", delete_path(model), class: 'btn btn--primary', data: { turbo_confirm: 'Are you sure?', confirm_details: "This will delete #{model.name}. This action cannot be undone." }`

The data attributes needed to make this work
- `turbo_confirm` (required) - Just like rails basic confirm functionality. This will be header text. E.g. "Are you sure?"
- `confirm_details` (optional, default: nil) - Provides additional details/text to the action the user about to take. E.g. "This will remove everything"
- additional content slots need to be configured. See @rolemodel/turbo-confirm on Github for details.

## Example Panel and Modal
Panel: `= panel_link_to 'Some link', panel_link_path, class: 'btn btn--primary'`
Modal: `= modal_link_to "Modal Test", new_model_path, class: 'btn btn--primary'`

Alternatively, just set the `data-turbo-frame=` attribute to either 'modal' or 'panel' directly.

Lastly, you'll need to pass in the `layout` keyword arg to `render` (or set the Controller class method) as either `modal` or `panel`, depending on which frame was targeted.

```ruby
class SomeController < ApplicationController
  def new
    render layout: 'modal'
  end
end
```
