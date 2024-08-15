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

    def create_assets_rake_tasks # rubocop:disable Metrics/MethodLength
      task_file = 'lib/tasks/assets.rake'

      say 'Add assets:minimize_footprint task that removes the node_modules directory.', :green

      create_file task_file, <<~RAKE
        # frozen_string_literal: true

        namespace :assets do
          desc 'Remove heavy node_modules directory when no longer needed.'
          task minimize_footprint: :environment do
            FileUtils.rm_rf(Rails.root.join('node_modules'))
          end
        end
      RAKE

      say '' # Add a newline
      say 'In production, assets:minimize_footprint can be run right after assets:precompile to significantly reduce slug size.', :yellow
      say 'If your application requires an asset that is not bundled by Webpack, you may need the node_modules folder to remain.', :yellow

      if no?('Leave node_modules directory in production slug? (y/n)')
        append_to_file task_file, <<~RAKE
          Rake::Task['assets:precompile'].enhance { Rake::Task['assets:cleanup'].invoke if Rails.env.production? }
        RAKE
      end
    end
  end
end
