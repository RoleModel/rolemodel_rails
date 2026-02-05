# frozen_string_literal: true

module Rolemodel
  module Testing
    class VitestGenerator < Rails::Generators::Base
      include ReplaceContentHelper
      source_root File.expand_path('templates', __dir__)

      TEST_COMMAND = 'NODE_ENV=test vitest'
      DEV_DEPENDENCIES = %w[
        playwright
        vitest
        @vitest/browser-playwright
        @vitest/ui
      ].freeze

      def updating_test_script
        say 'Update yarn test command', :green

        replace_content('package.json') do |json|
          hash = JSON.parse(json)
          hash['scripts'] ||= {}
          hash['scripts']['test'] = TEST_COMMAND
          JSON.pretty_generate(hash)
        end
      end

      def add_dev_dependencies
        say 'Adding new dev dependency to package.json', :green

        run "yarn add --dev #{DEV_DEPENDENCIES.join(' ')}"
      end

      def add_spec_config_files
        say 'Adding Vitest configuration files', :green

        template 'example.spec.js', 'spec/javascript/example.spec.js'
        template 'vitest.config.js', 'vitest.config.js'
        template 'test-setup.js', 'spec/javascript/test-setup.js'
      end
    end
  end
end
