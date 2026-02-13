# frozen_string_literal: true

module Rolemodel
  module Testing
    class RspecGenerator < ApplicationGenerator
      source_root File.expand_path('templates', __dir__)

      def install_rspec
        gem_group :development, :test do
          gem 'rspec-rails'
        end
        run_bundle

        gem_group :test do
          gem 'capybara-playwright-driver'
          gem 'marsh_grass'
          gem 'pry'
          gem 'webdrivers'
        end
        run_bundle
      end

      def install_playwright
        say 'Installing Playwright for system tests', :green

        run 'yarn add --dev playwright'
        run 'yarn run playwright install'
      end

      def add_spec_files
        template 'rails_helper.rb', 'spec/rails_helper.rb'
        template 'spec_helper.rb', 'spec/spec_helper.rb'
        template '.rspec', '.rspec'
        template 'support/capybara_drivers.rb', 'spec/support/capybara_drivers.rb'
        template 'support/capybara_testid.rb', 'spec/support/capybara_testid.rb'
        template 'support/helpers/action_cable_helper.rb', 'spec/support/helpers/action_cable_helper.rb'
        template 'support/helpers/capybara_helper.rb', 'spec/support/helpers/capybara_helper.rb'
        template 'support/helpers/playwright_helper.rb', 'spec/support/helpers/playwright_helper.rb'
        template 'support/helpers/select_helper.rb', 'spec/support/helpers/select_helper.rb'
        template 'support/helpers/test_element_helper.rb', 'spec/support/helpers/test_element_helper.rb'
        template 'support/helpers.rb', 'spec/support/helpers.rb'
        append_file '.gitignore', 'spec/examples.txt'
      end
    end
  end
end
