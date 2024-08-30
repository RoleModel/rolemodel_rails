require "bundler/setup"
require "rolemodel_rails"
require "rails/all"
require "rails/generators"
require "generator_spec"
require_relative "./support/helpers"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:all, type: :generator) do
    prepare_test_app
  end

  config.after(:all, type: :generator) do
    cleanup_test_app
  end
end
