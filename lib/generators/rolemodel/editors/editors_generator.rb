# frozen_string_literal: true

require_relative 'vscode_helpers'

module Rolemodel
  # Add standard editorconfig and any extensions to enable it
  class EditorsGenerator < ApplicationGenerator
    include Rolemodel::VSCodeHelpers

    # This is bringing in the root from this gem, so we only modify
    # one copy of .editorconfig for both this repo and any consumers.
    source_root File.expand_path('../../../../', __dir__)

    def add_editorconfig
      # Bring over the .editorconfig file for whitespace, etc.
      copy_file '.editorconfig'

      # Configuration for VSCode to recommend the EditorConfig extension.
      ensure_extensions_config

      # Presumably in the future, we might add ESLint, Rubocop, etc.
      # extensions. We might eventually also split this out, if there are
      # extensions for RubyMine or other editors, but in theory, we might
      # want to bring over config files for any RM-supported editors.
      inject_into_file '.vscode/extensions.json', after: '"recommendations": [' do
        "\n    \"EditorConfig.EditorConfig\","
      end
    end
  end
end
