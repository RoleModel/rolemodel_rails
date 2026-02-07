# frozen_string_literal: true

module Rolemodel
  module Linters
    class EslintGenerator < Rails::Generators::Base
      include ReplaceContentHelper
      source_root File.expand_path('templates', __dir__)

      ESLINT_COMMAND = "eslint 'app/**/*.js' 'spec/**/*.js'"
      DEV_DEPENDENCIES = %w[
        eslint
        eslint-config-airbnb
        eslint-plugin-import
        eslint-import-resolver-webpack
        eslint-plugin-jsx-a11y
        eslint-plugin-react
        eslint-plugin-react-hooks
      ].freeze

      def install_eslint
        run "yarn add --dev #{DEV_DEPENDENCIES.join(' ')}"
      end

      def add_config
        template 'eslint.config.js'
      end

      def add_eslint_command_to_package_json
        add_package_json_script 'eslint', ESLINT_COMMAND
      end
    end
  end
end
