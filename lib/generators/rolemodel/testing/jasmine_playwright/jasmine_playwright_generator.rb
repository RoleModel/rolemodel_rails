# frozen_string_literal: true

module Rolemodel
  module Testing
    class JasminePlaywrightGenerator < Rails::Generators::Base
      include ReplaceContentHelper
      source_root File.expand_path('templates', __dir__)
      class_option :github_package_token, type: :string, default: ENV['GITHUB_PACKAGES_TOKEN'],
                                          desc: 'GitHub Packages token with access to @rolemodel packages'

      TEST_COMMAND = 'NODE_ENV=test jp-runner --config jp-runner.config.mjs --webpack-config webpack.config.cjs'
      DEV_DEPENDENCIES = %w[
        @rolemodel/jasmine-playwright-runner
        playwright
        lit-html
      ].freeze

      def fail_without_github_token
        @add_jasmine = yes?('Would you like to add jasmine-playwright-runner for browser testing?')
        return unless @add_jasmine

        return unless options[:github_package_token].blank?

        raise 'a --github_package_token option or GITHUB_PACKAGES_TOKEN environment variable is required'
      end

      def yarn_init_unless_package_json_exists
        return unless @add_jasmine

        run 'yarn init' unless File.exist?(File.expand_path('package.json', destination_root))
      end

      def add_browser_test_script
        return unless @add_jasmine

        say 'Adding yarn test:browser command', :green

        replace_content('package.json') do |json|
          hash = JSON.parse(json)
          hash['scripts'] ||= {}
          hash['scripts']['test:browser'] = TEST_COMMAND
          JSON.pretty_generate(hash)
        end
      end

      def set_node_version
        return unless @add_jasmine

        say "Establish development environment Node version of #{set_color(NODE_VERSION, :yellow)}", :green

        create_file '.node-version', NODE_VERSION, force: true
      end

      def add_dev_dependencies
        return unless @add_jasmine

        say 'Adding new dev dependency to package.json', :green

        run "yarn add --dev #{DEV_DEPENDENCIES.join(' ')}"
      end

      def add_spec_config_files
        return unless @add_jasmine

        say 'Adding Jasmine Playwright configuration files', :green

        template 'example_spec.js', 'spec/javascript/browser/example_spec.js'
        template 'jp-runner.config.mjs', 'jp-runner.config.mjs'
        template 'setupTests.js', 'spec/javascript/browser/setupTests.js'
      end
    end
  end
end
