module Rolemodel
  class ReadmeGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    def install_readme
      @project_name = ask "What is the project name? Example: 'project_name':", :yellow
      template 'README.md.erb', 'README.md'
    end
  end
end
