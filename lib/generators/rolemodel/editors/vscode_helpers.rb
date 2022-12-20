# frozen_string_literal: true

module Rolemodel
  module VSCodeHelpers
    private

    # Create an extensions file for VSCode and provide an empty
    # recommendations array if it doesn't exist.
    def ensure_extensions_config
      return if File.exist?('.vscode/extensions.json')

      create_file('.vscode/extensions.json') do |file|
        <<~JSON
          {
            "recommendations": [
            ]
          }
        JSON
      end
    end
  end
end
