module Rolemodel
  class SlimGenerator < Rails::Generators::Base
    def add_slim
      run 'bundle add slim'
    end

    def replace_erb_layout
      remove_file 'app/views/layouts/application.html.erb'
      copy_file 'app/views/layouts/application.html.slim'
    end
  end
end
