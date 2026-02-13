module Rolemodel
  class ReadmeGenerator < ApplicationGenerator
    source_root File.expand_path('templates', __dir__)

    def install_readme
      @project_name = Rails.application.class.try(:parent_name) || Rails.application.class.module_parent_name
      @project = @project_name.underscore
      template 'README.md.erb', 'README.md'
    end
  end
end
