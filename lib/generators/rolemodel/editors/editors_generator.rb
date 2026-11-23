# frozen_string_literal: true

module Rolemodel
  # Add standard editorconfig and any extensions to enable it
  class EditorsGenerator < GeneratorBase
    # This is bringing in the root from this gem, so we only modify
    # one copy of .editorconfig for both this repo and any consumers.
    source_root File.expand_path('../../../../', __dir__)

    def add_editorconfig
      # Bring over the .editorconfig file for whitespace, etc.
      copy_file '.editorconfig'

      # Recommend the EditorConfig extension in VSCode. This creates .vscode/extensions.json
      # when it is missing. Presumably in the future, we might add ESLint, Rubocop, etc.
      # extensions, or config files for other RM-supported editors.
      # VS Code extension IDs ignore case, so an existing 'editorconfig.editorconfig' counts.
      modify_json_file('.vscode/extensions.json') do |config|
        recommendations = Array(config['recommendations'])
        unless recommendations.any? { it.casecmp?('EditorConfig.EditorConfig') }
          recommendations << 'EditorConfig.EditorConfig'
        end
        config['recommendations'] = recommendations
      end
    end
  end
end
