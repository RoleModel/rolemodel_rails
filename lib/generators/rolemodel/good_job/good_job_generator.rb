# frozen_string_literal: true

module Rolemodel
  class GoodJobGenerator < Rails::Generators::Base
    include BundlerHelpers
    source_root File.expand_path('templates', __dir__)

    def install_good_job
      say 'Install GoodJob'

      bundle_command 'add good_job'
      run_bundle

      generate 'good_job:install'
    end

    def configure_good_job
      say 'Add GoodJob configuration'

      inject_into_file 'config/application.rb', after: "class Application < Rails::Application\n" do
        optimize_indentation <<~'RUBY', 4
          # Add GoodJob ActiveJob queue adapter
          config.active_job.queue_adapter = :good_job

        RUBY
      end

      gsub_file 'config/environments/production.rb', 'config.active_job.queue_adapter', '# config.active_job.queue_adapter'
    end

    def configure_good_job_routes
      say 'Add GoodJob routes'

      route_text = <<~RUBY
        # Example but update per the authorization strategy of app
        namespace :admin do
          # authenticate :user, ->(user) { user.admin? } do
            mount GoodJob::Engine => 'good_job'
          # end
        end
      RUBY
      route route_text
    end

    def configure_procfile
      say 'Add GoodJob to Procfile'

      if File.exist?(Rails.root.join('Procfile'))
        append_to_file 'Procfile', <<~COMMAND
          worker: bundle exec good_job start
        COMMAND
      end

      append_to_file 'Procfile.dev', <<~COMMAND
        worker: bundle exec good_job start
      COMMAND
    end

    def copy_initializers
      say 'Add GoodJob initializers'

      copy_file 'config/initializers/active_job.rb'
      copy_file 'config/initializers/good_job.rb'
    end

    def finishing_notes
      say <<~NOTES
        *** Reminder to update Honeybadger gem to version 5.7.0 or later to get correct GoodJob error notifications in Honeybadger

        *** Reminder to also update your job classes to include appropriate concurrency controls (enqueue_limit/perform_limit with keys)
      NOTES
    end
  end
end
