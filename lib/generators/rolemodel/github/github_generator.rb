module Rolemodel
  class GithubGenerator < Rails::Generators::Base
    source_root File.expand_path('../../../../.github', __dir__)

    def install_pull_request_template
      template 'pull_request_template.md', '.github/pull_request_template.md'
    end

    def remove_rolemodel_rails_version_check
      gsub_file '.github/pull_request_template.md',
                "* [ ] Update version number in `lib/rolemodel_rails/version.rb`\n",
                ''
    end

    def install_copilot_instructions
      template 'instructions/css.instructions.md', '.github/instructions/css.instructions.md'
      template 'instructions/js.instructions.md', '.github/instructions/js.instructions.md'
      template 'instructions/project.instructions.md', '.github/instructions/project.instructions.md'
      template 'instructions/ruby.instructions.md', '.github/instructions/ruby.instructions.md'
      template 'instructions/slim.instructions.md', '.github/instructions/slim.instructions.md'
    end
  end
end
