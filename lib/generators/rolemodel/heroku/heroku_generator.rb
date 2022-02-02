module Rolemodel
  class HerokuGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    def install_app_json
      @project_name = Rails.application.class.try(:parent_name) || Rails.application.class.module_parent_name
      template 'app.json.erb', 'app.json'
    end

    def install_procfile
      template 'Procfile'
    end

    def force_ssl
      uncomment_lines('config/environments/production.rb', 'config.force_ssl = true')
    end

    def enable_log_level_configurability
      gsub_file('config/environments/production.rb', 'config.log_level = :info', "config.log_level = ENV.fetch('LOG_LEVEL', { 'INFO' })")
    end
  end
end
