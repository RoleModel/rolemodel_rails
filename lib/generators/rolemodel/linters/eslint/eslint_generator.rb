require_relative '../../../bundler_helpers'

module Rolemodel
  module Linters
    class EslintGenerator < Rails::Generators::Base
      include Rolemodel::BundlerHelpers
      source_root File.expand_path('templates', __dir__)

      def install_eslint
        packages = %w[
          eslint
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
        template '.eslintrc.cjs', '.eslintrc.cjs'
      end

      def add_eslint_command_to_package_json
        json = JSON.parse(File.read('package.json'))
        json['scripts'] = (json['scripts'] || {}).merge(
          eslint: "eslint .",
        )
        File.write('package.json', JSON.pretty_generate(json) + "\n")
      end
    end
  end
end
