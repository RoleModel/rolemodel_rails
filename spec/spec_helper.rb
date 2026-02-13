require 'bundler/setup'
require 'generator_spec'
require_relative 'support/helpers'
require 'generators/rolemodel'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:each, type: :generator) do
    prepare_test_app
  end

  config.after(:each, type: :generator) do
    cleanup_test_app
  end
end
