module Rolemodel
  class HerokuGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    def install_bin_heroku_release
      template 'bin/heroku_release'
      # -rwxr-xr-x
      chmod 'bin/heroku_release', 0755 & ~File.umask, verbose: false
    end

    def install_app_json
      @project_name = Rails.application.class.parent_name
      template 'app.json.erb', 'app.json'
    end

    def install_procfile
      template 'Procfile'
    end
  end
end
