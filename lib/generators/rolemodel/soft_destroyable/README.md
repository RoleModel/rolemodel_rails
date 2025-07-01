# Soft Destroyable Generator

## What you get

* Ruby module for SoftDestroyable
* Shared example file for testing your classes

Adds module for soft destroyable of ActiveRecord classes with configurable cascading of association data

## Association management

```ruby
# to nullify associations on soft_destroy
after_soft_destroy :cascade_soft_destroy_nullify

# to cascade soft_destroy
cascade_soft_destroy :models_to_soft_destroy, :other_models_to_soft_destroy
```
