require_relative '../../../bundler_helpers'

module Rolemodel
  module Testing
    class RspecGenerator < Rails::Generators::Base
      include Rolemodel::BundlerHelpers
      source_root File.expand_path('templates', __dir__)

      def install_rspec
        gem_group :development, :test do
          gem 'rspec_junit_formatter'
          gem 'rspec-rails'
          gem 'turbo_tests'
        end
        run_bundle

        gem_group :test do
          gem 'capybara'
          gem 'selenium-webdriver'
        end
        run_bundle
      end

      def add_spec_files
        template 'rails_helper.rb', 'spec/rails_helper.rb'
        template 'spec_helper.rb', 'spec/spec_helper.rb'
        template '.rspec', '.rspec'
        template '.rspec_parallel', '.rspec_parallel'
        template 'support/capybara_drivers.rb', 'spec/support/capybara_drivers.rb'
        template 'support/capybara_testid.rb', 'spec/support/capybara_testid.rb'
        template 'support/helpers/capybara_helper.rb', 'spec/support/helpers/capybara_helper.rb'
        template 'support/helpers/download_helper.rb', 'spec/support/helpers/download_helper.rb'
        template 'support/helpers/test_element_helper.rb', 'spec/support/helpers/test_element_helper.rb'
        template 'support/helpers.rb', 'spec/support/helpers.rb'
        append_file '.gitignore', 'spec/examples.txt'
      end

      def modify_existing_files
        # Configure for paralell_spec
        gsub_file 'config/database.yml', /database: .*_test$/ do |match|
          "#{match}<%= ENV['TEST_ENV_NUMBER'] %>"
        end
      end
    end
  end
end
