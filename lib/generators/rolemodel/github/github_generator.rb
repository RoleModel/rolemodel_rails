# frozen_string_literal: true

module Rolemodel
  class GithubGenerator < BaseGenerator
    # Source root is the project-level .github directory
    # This allows us to use the same templates for both the generated app and this gem
    source_root File.expand_path('.github')

    def install_pull_request_template
      template 'pull_request_template.md', '.github/pull_request_template.md'
    end

    def remove_rolemodel_rails_version_check
      gsub_file '.github/pull_request_template.md',
                "* [ ] Run `bin/bump_version` or `bin/bump_version --patch`\n",
                ''
    end

    def install_copilot_instructions
      copy_file 'copilot-instructions.md', '.github/copilot-instructions.md'
      copy_file 'instructions/js.instructions.md', '.github/instructions/js.instructions.md'
      copy_file 'instructions/ruby_model.instructions.md', '.github/instructions/ruby_model.instructions.md'
      copy_file 'instructions/slim.instructions.md', '.github/instructions/slim.instructions.md'
    end

    def install_copilot_skills
      copy_skill 'bem-structure'
      copy_skill 'controller-patterns'
      copy_skill 'dynamic-nested-attributes'
      copy_skill 'form-auto-save'
      copy_skill 'frontend-patterns'
      copy_skill 'json-typed-attributes'

      copy_skill 'optics-context'
      copy_file 'skills/optics-context/assets/components.json', '.github/skills/optics-context/assets/components.json'
      copy_file 'skills/optics-context/assets/tokens.json', '.github/skills/optics-context/assets/tokens.json'

      copy_skill 'routing-patterns'
      copy_skill 'stimulus-controllers'
      copy_skill 'testing-patterns'
      copy_skill 'theming-context'
      copy_skill 'turbo-fetch'
    end

    def install_ci_yml
      copy_file 'templates/ci.yml', '.github/workflows/ci.yml'
    end

    def update_database_yml_for_ci
      insert_into_file 'config/database.yml', after: /database: .*_test.*\n/ do
        optimize_indentation <<~YML, 2
          <% if ENV.has_key?("POSTGRES_USER") %>
          username: <%= ENV.fetch("POSTGRES_USER") %>
          password: <%= ENV.fetch("POSTGRES_PASSWORD") { nil } %>
          host: localhost
          <% end %>
        YML
      end
    end

    private

    def copy_skill(name)
      copy_file "skills/#{name}/SKILL.md", ".github/skills/#{name}/SKILL.md"
    end
  end
end
