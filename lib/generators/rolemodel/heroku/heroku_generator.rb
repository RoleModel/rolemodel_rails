module Rolemodel
  class HerokuGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    def install_app_json
      @project_name = Rails.application.class.parent_name
      template 'app.json.erb', 'app.json'
    end

    def install_procfile
      template 'Procfile'
    end
  end
end
