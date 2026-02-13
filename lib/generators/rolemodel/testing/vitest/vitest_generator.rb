# frozen_string_literal: true

module Rolemodel
  module Testing
    class VitestGenerator < ApplicationGenerator
      include ReplaceContentHelper
      source_root File.expand_path('templates', __dir__)

      TEST_COMMAND = 'NODE_ENV=test vitest'
      DEV_DEPENDENCIES = %w[
        playwright
        vitest
        @vitest/browser-playwright
        @vitest/ui
      ].freeze

      def update_test_script
        say 'Update yarn test command', :green

        add_package_json_script 'test', TEST_COMMAND
      end

      def add_dev_dependencies
        say 'Adding new dev dependency to package.json', :green

        run "yarn add --dev #{DEV_DEPENDENCIES.join(' ')}"
      end

      def add_spec_config_files
        say 'Adding Vitest configuration files', :green

        template 'spec/javascript/example.spec.js'
        template 'vitest.config.js'
        template 'spec/javascript/test-setup.js'
      end
    end
  end
end
