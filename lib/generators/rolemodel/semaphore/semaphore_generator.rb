module Rolemodel
  class SemaphoreGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    def create_base_semaphore_config
      @project_name = Rails.application.class.try(:parent_name) || Rails.application.class.module_parent_name
      template 'semaphore.yml.erb', '.semaphore/semaphore.yml'

      if yes?('Does your project have JavaScript tests?')
        uncomment_lines('.semaphore/semaphore.yml', '- yarn test')
        uncomment_lines('.semaphore/semaphore.yml', '- yarn run eslint')
      end
    end

    def create_deplyment_commands
      @project_name = Rails.application.class.try(:parent_name) || Rails.application.class.module_parent_name

      template 'heroku-deployment-commands.sh', '.semaphore/heroku-deployment-commands.sh'
      template 'staging-deploy.yml.erb', '.semaphore/staging-deploy.yml'
      template 'production-deploy.yml.erb', '.semaphore/production-deploy.yml'
    end
  end
end
