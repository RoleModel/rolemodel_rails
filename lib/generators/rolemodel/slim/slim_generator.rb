module Rolemodel
  class SlimGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    def add_slim
      run 'bundle add slim'
    end

    def replace_erb_layout
      remove_file 'app/views/layouts/application.html.erb'
      template 'app/views/layouts/application.html.slim'
    end
  end
end
