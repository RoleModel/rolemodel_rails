# frozen_string_literal: true

module Rolemodel
  module Testing
    class RspecGenerator < GeneratorBase
      source_root File.expand_path('templates', __dir__)

      class_option :marsh_grass, type: :boolean, default: false, desc: 'Include marsh_grass for debugging RSpec tests'

      def install_rspec
        say 'Installing RSpec-rails', :green

        bundle_command('add rspec-rails --group "development, test"')
      end

      def install_system_test_driver
        say 'Installing capybara-playwright-driver for system tests', :green

        bundle_command('add capybara-playwright-driver --group "test"')
        bundle_command('add marsh_grass --group "test"') if options.marsh_grass?
      end

      def bundle_install
        run_bundle
      end

      def install_playwright
        say 'Installing Playwright for system tests', :green

        ensure_yarn
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
