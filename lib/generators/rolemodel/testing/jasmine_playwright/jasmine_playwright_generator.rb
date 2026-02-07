# frozen_string_literal: true

module Rolemodel
  module Testing
    class JasminePlaywrightGenerator < Rails::Generators::Base
      include ReplaceContentHelper
      source_root File.expand_path('templates', __dir__)
      class_option :github_package_token, type: :string, default: ENV['GITHUB_PACKAGES_TOKEN'], desc: 'GitHub Packages token with access to @rolemodel packages'

      TEST_COMMAND = 'NODE_ENV=test jp-runner --config jp-runner.config.mjs --webpack-config webpack.config.cjs'
      DEV_DEPENDENCIES = %w[
        @rolemodel/jasmine-playwright-runner
        playwright
        lit-html
      ].freeze

      def fail_without_github_token
        raise 'a --github_package_token option or GITHUB_PACKAGES_TOKEN environment variable is required' if options[:github_package_token].blank?
      end

      def yarn_init_unless_package_json_exists
        run 'yarn init' unless File.exist?(File.expand_path('package.json', destination_root))
      end

      def add_browser_test_script
        say 'Adding yarn test:browser command', :green

        add_package_json_script 'test:browser', TEST_COMMAND
      end

      def set_node_version
        say "Setting local Node version to #{set_color(NODE_VERSION, :yellow)}", :green

        create_file '.node-version', NODE_VERSION, force: true
      end

      def add_dev_dependencies
        say 'Adding new dev dependency to package.json', :green

        run "yarn add --dev #{DEV_DEPENDENCIES.join(' ')}"
      end

      def add_spec_config_files
        say 'Adding Jasmine Playwright configuration files', :green

        template 'spec/javascript/browser/example_spec.js'
        template 'jp-runner.config.mjs'
        template 'spec/javascript/browser/setupTests.js'
      end
    end
  end
end
