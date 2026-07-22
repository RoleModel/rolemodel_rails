module Rolemodel
  class HerokuGenerator < GeneratorBase
    source_root File.expand_path('templates', __dir__)

    def install_app_json
      say 'Install app.json file', :green

      @project_name = Rails.application.class.try(:parent_name) || Rails.application.class.module_parent_name
      template 'app.json'
    end

    def install_procfile
      say 'Install Procfile', :green

      template 'Procfile'
    end

    def pin_ruby_version_for_buildpack
      say 'Pin the Ruby version in the Gemfile so the Heroku buildpack respects it.', :green

      # A bare .ruby-version file is not enough: without a `ruby` directive the version
      # never lands in Gemfile.lock, so the Heroku Ruby buildpack falls back to its own
      # default and can install an incompatible Ruby. Tie the Gemfile to .ruby-version.
      gemfile = File.join(destination_root, 'Gemfile')
      return if File.exist?(gemfile) && File.read(gemfile).match?(/^\s*ruby\s/)

      inject_into_file 'Gemfile', "\nruby file: '.ruby-version'\n", after: /^source .*$/
    end

    def force_ssl
      say 'Require SSL for production environment.', :green

      uncomment_lines('config/environments/production.rb', 'config.force_ssl = true')
    end

    def enable_log_level_configurability
      say 'Enable log-level adjustment via "LOG_LEVEL" environment variable', :green

      gsub_file(
        'config/environments/production.rb',
        'config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")',
        "config.log_level = ENV.fetch('LOG_LEVEL', 'INFO')"
      )
      gsub_file('config/environments/production.rb', 'config.log_level = :info', "config.log_level = ENV.fetch('LOG_LEVEL', 'INFO')")
    end

    def create_assets_rake_tasks # rubocop:disable Metrics/MethodLength
      say 'Enhancing assets:precompile task to remove node_modules directory during production build.', :green
      rakefile('assets.rake', <<~RAKE)
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

    def show_deploy_app_skill_path
      # The deploy-app skill is one-time deployment setup, so it ships inside the
      # rolemodel-rails gem instead of being copied into the app. Point the user
      # at it so they can hand it to a coding agent when they're ready to deploy.
      say "\nWhen you're ready to deploy, point your coding agent at the deploy-app skill:", :green
      say File.expand_path('templates/deploy-app/SKILL.md', __dir__), :yellow
    end
  end
end
