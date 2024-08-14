module Rolemodel
  class HerokuGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    def install_app_json
      say 'Install app.json file', :green

      @project_name = Rails.application.class.try(:parent_name) || Rails.application.class.module_parent_name
      template 'app.json.erb', 'app.json'
    end

    def install_procfile
      say 'Install Procfile', :green

      template 'Procfile'
    end

    def force_ssl
      say 'Require SSL for production environment.', :green

      uncomment_lines('config/environments/production.rb', 'config.force_ssl = true')
    end

    def enable_log_level_configurability
      say 'Enable log-level adjustment via "LOG_LEVEL" environment variable', :green

      gsub_file('config/environments/production.rb', 'config.log_level = :info', "config.log_level = ENV.fetch('LOG_LEVEL', 'INFO')")
    end

    def create_assets_rake_tasks
      say 'Enhance precompile task to remove heavy node_modules directory after build.', :green

      create_file 'lib/tasks/assets.rake', <<~RAKE
        # frozen_string_literal: true
        
        namespace :assets do
          task cleanup: :environment do
            puts 'Removing node_modules...'
            FileUtils.rm_rf(Rails.root.join('node_modules'))
          end
        end
        Rake::Task['assets:precompile'].enhance { Rake::Task['assets:cleanup'].invoke }
      RAKE
    end
  end
end
