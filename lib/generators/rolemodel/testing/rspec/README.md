# RSpec Generator

## What you get

### RSpec Default

Based of rspec-rails install generator. Assume all configuration will be placed in `spec/support/*.rb`

### System Tests

Released with rails 5.1, these tests cover end to end functionality.

### Helpers

In addition to setting this up, we've added a way to include domain specific test helpers for your tests in the `spec/support/helpers`. These files can be included in [support/helpers.rb](./templates/support/helpers.rb)


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

#### Overriding
The `CAPYBARA_DRIVER` environment variable can be set to either `js`, `chrome` or `firefox` to override the entire suite.
This is especially useful for running the entire sweet with headless capybara in CI

