module Rolemodel
  class ReadmeGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    def install_readme
      template 'README.md', 'README.md'
    end
  end
end
