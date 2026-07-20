# Confirm Generator

Add custom dialog support to `data-turbo-confirm`

## Prerequisites

* `rolmodel:slim`
* `rolemodel:webpack`

## What you get

* Custom confirm dialogs via `@rolemodel/turbo-confirm` integration

## Example

```slim
  = button_to "Test Confirm", model, method: :delete, data: { \
    turbo_confirm: "For real?!?",
    confirm_details: "You're about to delete #{model.name}, forever. 😱",
    confirm_button: "YOLO!",
  }
```

data attributes other than `turbo-confirm` are optional & customizable.  See [turbo-confirm](https://github.com/RoleModel/turbo-confirm) for more details.
