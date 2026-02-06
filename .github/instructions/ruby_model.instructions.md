---
applyTo: 'app/models/*.rb'
---

Models use ActiveRecord for database interactions and should follow Rails conventions. Always prefer ActiveRecord scopes over AREL and AREL over plain SQL.

## Enums

Enums columns should be a string in the database and be defined in the model as follows:
```ruby
enum :my_enum, {
  option_one: 'option_one',
  option_two: 'option_two',
  option_three: 'option_three'
}
```
Never create a scope if an Enum already exists for the same purpose.

## Validations

When multiple fields match a validation, use the `validates` method with an array:
```ruby
validates :field_one, :field_two, presence: true
```

## Scopes
- Please only create scopes that are used in multiple places. If a scope is only used once, it should be defined inline in the query.
- Don't pre-emptively create scopes for every possible query. Instead, create them as needed based on actual use cases.
