# RSpec Generator

## What you get

### RSpec Default

Based of rspec-rails install generator. Assume all configuration will be placed in `spec/support/*.rb`

### System Tests

Released with rails 5.1, these tests cover end to end functionality.

In addition to setting this up, we've added a way to include test helpers for your system tests in the `spec/system/helpers`. These files can be included in [support/system_tests.rb](./templates/support/system_tests.rb)


### Capybara Drivers

Simple short hand for using real browsers to drive your tests.

#### headless

```rb
it 'saves the form data', :js do
  # ...some test
end
```

#### Chrome - visible browser

```rb
it 'saves the form data', :chrome do
  # ...some test
end
```

#### Firefox - visible browser

```rb
it 'saves the form data', :firefox do
  # ...some test
end
```
