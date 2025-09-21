# frozen_string_literal: true
require_relative '../../../replace_content_helper'

module Rolemodel
  module Testing
    class JasminePlaywrightGenerator < Rails::Generators::Base
      include Rolemodel::ReplaceContentHelper
      source_root File.expand_path('templates', __dir__)

      NODE_VERSION = '22.15.0'

      TEST_COMMAND = 'NODE_ENV=test jp-runner --config jp-runner.config.mjs --webpack-config webpack.config.cjs'

      # TODO: Yarn can't find this package: @rolemodel/jasmine-playwright-runner
      DEV_DEPENDENCIES = %w[
        playwright
        lit-html
      ].freeze

      def add_jasmine_playwright_script
        raise 'package.json not found. Please run yarn init first.' unless File.exist?(File.expand_path('package.json', destination_root))

        replace_content('package.json') do |json|
          hash = JSON.parse(json)
          hash['scripts'] ||= {}
          hash['scripts']['test:browser'] = TEST_COMMAND
          JSON.pretty_generate(hash)
        end
      end

      def ensure_node_version
        say "Establish development environment Node version of #{set_color(NODE_VERSION, :yellow)}", :green

        create_file '.node-version', NODE_VERSION, force: true
      end

      def add_npm_packages
        say 'Adding new dev dependency to package.json', :green
        run "yarn add --dev #{DEV_DEPENDENCIES.join(' ')}"
      end

      def add_spec_files
        template 'example_spec.js', 'spec/javascript/browser/example_spec.js'
        template 'jp-runner.config.mjs', 'jp-runner.config.mjs'
        template 'setupTests.js', 'spec/javascript/browser/setupTests.js'
      end
    end
  end
end
