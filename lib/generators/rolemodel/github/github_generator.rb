module Rolemodel
  class GithubGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    def install_pull_request_template
      template 'pull_request_template.md', '.github/pull_request_template.md'
    end
  end
end
