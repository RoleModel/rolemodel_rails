# frozen_string_literal: true

module Rolemodel
  class GithubGenerator < ApplicationGenerator
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
      copy_file 'instructions/css.instructions.md', '.github/instructions/css.instructions.md'
      copy_file 'instructions/js.instructions.md', '.github/instructions/js.instructions.md'
      copy_file 'instructions/project.instructions.md', '.github/instructions/project.instructions.md'
      copy_file 'instructions/ruby.instructions.md', '.github/instructions/ruby.instructions.md'
      copy_file 'instructions/slim.instructions.md', '.github/instructions/slim.instructions.md'
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
  end
end
