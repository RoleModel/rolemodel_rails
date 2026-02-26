# frozen_string_literal: true

module Rolemodel
  class GithubGenerator < BaseGenerator
    # Files which are both used by the gem source and copied to the target app without modification
    # are placed in the `.github` folder at the top level of this repository. This folder is then
    # symlinked to the `templates` folder relative to this generator so they can still be copied over.
    # Any files which are significantly different or not used by the gem source are just in `templates`.
    source_root File.expand_path('templates', __dir__)

    def install_github_config
      directory 'instructions', '.github/instructions'
      directory 'workflows', '.github/workflows'
      template 'pull_request_template.md', '.github/pull_request_template.md'
    end

    def install_dependabot_and_codeowners
      copy_file 'dependabot.yml', '.github/dependabot.yml'
      copy_file 'CODEOWNERS', '.github/CODEOWNERS'

      say '👉 See CODEOWNERS file for important instructions.', %i[bold red on_blue]
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
