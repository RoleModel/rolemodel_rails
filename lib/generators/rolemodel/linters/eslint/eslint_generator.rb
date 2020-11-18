require_relative '../../../bundler_helpers'

module Rolemodel
  module Linters
    class EslintGenerator < Rails::Generators::Base
      include Rolemodel::BundlerHelpers
      source_root File.expand_path('templates', __dir__)

      def install_eslint
        packages = %w[
          eslint
          babel-eslint
          eslint-config-airbnb
          eslint-plugin-import
          eslint-import-resolver-webpack
          eslint-plugin-jsx-a11y
          eslint-plugin-react
          eslint-plugin-react-hooks
        ]
        run "yarn add --dev #{packages.join(' ')}"
      end

      def add_config
        template '.eslintrc.js', '.eslintrc.js'
      end
    end
  end
end
