module Rolemodel
  class SemaphoreGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    def create_base_semaphore_config
      @project_name = Rails.application.class.try(:parent_name) || Rails.application.class.module_parent_name
      @js = yes?('Does your project have JavaScript tests?')
      template 'semaphore.yml.erb', '.semaphore/semaphore.yml'
    end

    # def install_procfile
    #   template 'Procfile'
    # end

    # def force_ssl
    #   uncomment_lines('config/environments/production.rb', 'config.force_ssl = true')
    # end

    # def enable_log_level_configurability
    #   gsub_file('config/environments/production.rb', 'config.log_level = :info', "config.log_level = ENV.fetch('LOG_LEVEL', 'INFO')")
    # end
  end
end
