module Rolemodel
  class ReadmeGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    def install_readme
      @project_name = Rails.application.class.parent_name
      @project = @project_name.underscore
      template 'README.md.erb', 'README.md'
    end
  end
end
