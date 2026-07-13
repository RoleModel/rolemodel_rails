# TailoredSelect Generator

`rails g rolemodel:tailored_select`

## What you get

The [Tailored Select](https://github.com/RoleModel/tailored-select) web component

## Coupling with simple_form

When `rolemodel:simple_form` is recorded in the app's generator registry,
the tailored_select generator installs its SimpleForm input template
(`app/inputs/tailored_select_input.rb`) automatically.

* Standalone install (without simple_form): installs only the JS package.
* Pass `--simple-form-input` to force the input installation regardless of
  registry state.
* Pass `--no-simple-form-input` to suppress it.
* The simple_form generator can delegate this explicitly with
  `--tailored-select`, which forces the input during that child run.
