# frozen_string_literal: true

module Rolemodel
  module Testing
    class RspecGenerator < GeneratorBase
      source_root File.expand_path('templates', __dir__)

      class_option :marsh_grass, type: :boolean, default: false, desc: 'Include marsh_grass for debugging RSpec tests'

      def install_rspec
        say 'Installing RSpec-rails', :green

        gem_group :development, :test do
          gem 'rspec-rails'
        end

        say 'Installing capybara-playwright-driver for system tests', :green

        gem_group :test do
          gem 'capybara-playwright-driver'

          if options.marsh_grass?
            gem 'marsh_grass'
            gem 'pry'
          end
        end
        run_bundle
      end

      def install_playwright
        say 'Installing Playwright for system tests', :green

        run 'yarn add --dev playwright'
        run 'yarn run playwright install'
      end

      def add_spec_files
        say 'Adding Support Files', :green

        directory 'spec'

        append_file '.gitignore', 'spec/examples.txt'
      end
    end
  end
end
