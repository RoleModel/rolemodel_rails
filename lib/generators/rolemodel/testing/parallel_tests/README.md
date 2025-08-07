# Parallel Tests Generator

## What you get

### Parallel Tests Setup

This generator configures your Rails application to run RSpec tests in parallel, greatly reducing the time it takes to run your test suite.

### Gemfile Addition

The generator will add the `parallel_tests` gem to your Gemfile and run bundle install.

```rb
group :development, :test do
  gem 'parallel_tests'
end
```

### Database Configuration

Your `database.yml` will be updated to support parallel test databases. This allows each test process to use its own isolated database.

```yaml
test:
  # ...existing configuration...
  database: your_app_test<%= ENV['TEST_ENV_NUMBER'] %>
```

### Running Parallel Tests

Once configured, you can run your tests in parallel using:

```bash
# Run entire test suite in parallel
bundle exec rake parallel:spec

# Run specific tests in parallel
bundle exec rake parallel:spec[spec/models]

# Specify number of processes (default is the number of CPUs)
bundle exec rake parallel:spec[spec,4]
```
