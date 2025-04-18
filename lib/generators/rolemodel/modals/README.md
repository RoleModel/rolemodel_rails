# Modal and Panel Generator

## What you get

* Custom confirm dialogs via `@rolemodel/turbo-confirm` integration
* Modal and panel styling ..via `@rolemodel/optics` integration
* Modal and panel layouts w/ link helpers (or you could just, e.g. `link_to ... data: {turbo_frame: 'modal'}`)
* frame-missing handler with Turbo v8 morphing support.
* Stimulus `toggle` controller to help with modal/panel animations.
* initializer for turbo-confirm package.
* some generally useful, global Turbo before-morph handlers.

## After install (Update Only)

1. This generator does not currently attempt to remove the old RoleModel Modal/Confirm/Panel or MakeFormsRemote javascript files or initialization code.  However, that code needs to be removed for the new process to work correctly.
2. Remove Rails-UJS from your project. Most likely that means running `yarn remove @rails/ujs` and then deleting the `import` and `start()` statements from application.js.
3. Ensure your application layout now includes the *empty* `turbo_frame_tag`s for `modal` & `panel` as well as the new confirm partial.  The generator should have done this but it may have failed if your layout is much different than expected.

## Turbo confirm example

```slim
  = button_to "Test Confirm", model, method: :delete, data: { \
    turbo_confirm: "For real?!?",
    confirm_details: "You're about to delete #{model.name}, forever. 😱",
    confirm_button: "YOLO!",
  }
```

data attributes other than `turbo-confirm` are optional.  See [turbo-confirm](https://github.com/RoleModel/turbo-confirm) for more details.

## Modal & Panel examples

Modal: (the following 2 examples are equivalent)

* `= link_to 'Modal Test', some_modal_layout_action_path, data: { turbo_frame: 'modal' }`
* `= modal_link_to 'Modal Test', some_modal_layout_action_path`

Panel: (the following 2 examples are equivalent)

* `= link_to 'Panel Test', some_panel_layout_action_path, data: { turbo_frame: 'panel' }`
* `= panel_link_to 'Panel Test', some_panel_layout_action_path`

You'll then need to pass the `layout` kwarg when calling `render` with either `modal` or `panel`, depending on which frame is being targeted.  (We recommend against the `layout` controller class method, because it causes *layout fallback* issues when the controller is subclassed.)

e.g.

```ruby
class SomethingsController < ApplicationController
  def new
    render layout: 'modal'
  end
end
```

## TurboFrame modal & panel forms

There are a couple of important rules when it comes to TurboFrames & forms.

1. In the case of errors, your controller action must respond with `status: :unprocessable_entity` *HTTP status code __422__* in order to re-render your form w/ errors.  This is both a Turbo requirement, as well as the mechanism which prevents the modal or panel from re-animating in.
2. In the case of success, your controller action must redirect.  This is a Turbo requirement in Rails 7+
3. Never use the `layout` class method in your controllers.
   * If you absolutely must use the `layout` class method, it might be worth considering a re-design in which its no longer necessary.
   * As a very last resort, you may call the `layout` class method with the symbolized name of a method which conditionally returns false e.g. `'my_special_layout' unless turbo_frame_request?`

e.g.

```ruby
class SomethingsController < ApplicationController
  def new
    @something = authorize Something.new
    render layout: 'modal'
  end

  def create
    @something = authorize Something.new(some_params)

    if @something.save
      redirect_to @something, notice: 'Something created successfully'
    else
      render :new, status: :unprocessable_entity, layout: 'modal'
    end
  end
end
```

## Modal header & footer

The included modal layout includes *slots* for title content & submit buttons, in addition to the main content `yield`.  You may, of course remove these sections if they don't match your use-case.  Otherwise, the following is an example edit template meant to be rendered in the modal layout.

```slim
= content_for :modal_title do
  h2 Edit the thing

= content_for :modal_actions do
  = button_tag 'Save', class: 'btn btn--primary', form: dom_id(@thing, :edit)

= simple_form_for @thing do |f|
  = f.input :name
  = f.input :description
```

__note:__ the submit button in the `new.html.slim` version of this template would be `form: dom_id(@thing)` or simply `form: 'new_thing'`.

Alternatively, it's still possible to nest the `content_for` block within the form builder if you need to leverege button text generation, for example.  Though you __must__ still set the `form` attribute explicitly, because the button (or `input[type='submit']` in this case) will ultimately be rendered outside of the `<form></form>` tags. e.g.

```slim
= simple_form_for @thing do |f|
  = f.input :name
  = f.input :description

  = content_for :modal_actions do
    = f.submit form: f.id
```

For further explanation of form Id generation, see the [Record Identifier](https://api.rubyonrails.org/classes/ActionView/RecordIdentifier.html) and [polymorphic Routes](https://api.rubyonrails.org/classes/ActionDispatch/Routing/PolymorphicRoutes.html) docs, or simply inspect the form element in your browser.
