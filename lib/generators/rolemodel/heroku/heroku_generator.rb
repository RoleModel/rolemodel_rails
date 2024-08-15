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

      say 'Enhancing assets:precompile task to remove node_modules directory during production build.', :green
      create_file task_file, <<~RAKE
        # All runtime asset dependencies should be bundled by Webpack during asset precompilation.
        # Therefore, the node_modules directory can be removed after assets are compiled to significantly reduce slug size.
        # In rare cases, you may have a runtime dependency into node_modules directly. If this is the case and you are unable
        # to bundle the dependency, delete this file and the node_modules directory will be included in your production slug.

        Rake::Task['assets:precompile'].enhance do
          if Rails.env.production?
            puts '----> Removing node_modules directory to reduce slug size.'
            FileUtils.rm_rf(Rails.root.join('node_modules'))
          end
        end
      RAKE
    end
  end
end
