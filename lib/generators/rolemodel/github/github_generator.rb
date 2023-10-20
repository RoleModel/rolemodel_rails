module Rolemodel
  class GithubGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    def install_pull_request_template
      template 'pull_request_template.md', '.github/pull_request_template.md'
    end

    def add_idea_to_gitignore
      # Ignore the rubymine config directory
      inject_into_file '.gitignore', "\n/.idea\n"
    end
  end
end
