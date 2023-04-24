# Modal and Panel Generator

## What you get

* Custom confirm dialogs via `@rolemodel/turbo-confirm` integration
* Modal and panel styling ..via `@rolemodel/optics` integration
* Modal and panel layouts w/ link helpers (or you could just, e.g. `link_to ... data: {turbo_frame: 'modal'}`)
* frame-missing handler (required for turbo-rails v1.4.0 and above)

Adds UI and JavaScript for opening modals and the panel within a Rails view

## Example delete confirmation link

```ruby
  = button_to "Test Confirm", model, method: :delete, class: "btn btn--primary", data: { \
    turbo_confirm: "Are you sure you want to delete #{model.name}?",
    confirm_details: "This action cannot be undone.",
    confirm_button: "Make it so!",
  }
```

data attributes other than `turbo-confirm` are optional.  See [turbo-confirm](https://github.com/RoleModel/turbo-confirm) for details.

## Example Panel and Modal

Modal: `= link_to "Modal Test", action_which_responds_with_modal_layout_path, class: "btn btn--primary", data: { turbo_frame: "modal" }`
Panel: `= link_to "Panel Test", action_which_responds_with_panel_layout_path, class: "btn btn--primary", data: { turbo_frame: "panel" }`

Lastly, you'll need to pass in the `layout` keyword arg to `render` (or set the Controller class method) as either `modal` or `panel`, depending on which frame was targeted.

```ruby
class SomeController < ApplicationController
  def new
    render layout: 'modal'
  end
end
```
