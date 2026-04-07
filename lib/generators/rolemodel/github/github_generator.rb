# frozen_string_literal: true

module Rolemodel
  class GithubGenerator < GeneratorBase
    GITHUB_ACTIONS_REPO = 'https://github.com/RoleModel/actions.git'
    # Files which are both used by the gem source and copied to the target app without modification
    # are placed in the `.github` folder at the top level of this repository. This folder is then
    # symlinked to the `templates` folder relative to this generator so they can still be copied over.
    # Any files which are significantly different or not used by the gem source are just in `templates`.
    source_root File.expand_path('templates', __dir__)

    class_option :playwright, type: :boolean, default: true,
                 desc: 'Request Playwright Setup in CI workflow for system tests?'

    def set_rm_actions_version
      tags = `git ls-remote --tags #{GITHUB_ACTIONS_REPO}` rescue 'refs/tags/v3'
      @rm_actions_version = tags.scan(%r{refs/tags/v(\d+)\s*$}).flatten.max_by(&:to_i)
    end

    def set_webdriver
      @webdriver = options.playwright? ? 'playwright' : 'selenium'
    end

    def install_github_config
      directory 'instructions', '.github/instructions'
      directory 'workflows', '.github/workflows', force: true
      template 'pull_request_template.md', '.github/pull_request_template.md'
    end

    def install_dependabot_and_codeowners
      copy_file 'dependabot.yml', '.github/dependabot.yml', force: true
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
