# frozen_string_literal: true

module Rolemodel
  module Testing
    class ParallelTestsGenerator < Rails::Generators::Base # rubocop:disable Style/Documentation
      include BundlerHelpers
      source_root File.expand_path('templates', __dir__)

      def install_parallel_tests
        gem_group :development, :test do
          gem 'parallel_tests'
          gem 'turbo_tests', require: false
          gem 'rspec_junit_formatter', require: false
        end
        run_bundle
      end

      def add_rspec_parallel_file
        template '.rspec_parallel', '.rspec_parallel'
      end

      def configure_database_for_parallel_testing
        say_status :update, 'Updating database.yml for parallel testing', :blue

        # If there is, append the TEST_ENV_NUMBER to it
        gsub_file 'config/database.yml', /(test:.*\n\s+database:.*_test)/m, "\\1<%= ENV['TEST_ENV_NUMBER'] %>"

        say_status :update, 'Updated database configuration successfully', :green
      end

      def setup_parallel_test_databases
        say_status :setup, 'Setting up parallel test databases...', :blue
        run 'bundle exec rake parallel:setup'
      end

      def display_post_install_message
        say_status :info, 'Parallel Tests has been configured!', :green
        say_status :info, 'You can now run your tests in parallel with:', :green
        say_status :info, 'bundle exec rake parallel:spec', :green
      end
    end
  end
end
