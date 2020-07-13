require_relative '../../../bundler_helpers'

module Rolemodel
  module Saas
    class DeviseGenerator < Rails::Generators::Base
      include Rolemodel::BundlerHelpers
      source_root File.expand_path('templates', __dir__)

      def install_devise
        gem 'devise'
        run_bundle

        generate 'devise:install'
        generate :devise, 'user first_name:string last_name:string'
      end

      def add_invitable
        @add_invitable = yes?('Would you like to add user invitations?')
        if @add_invitable
          gem 'devise_invitable'
          run_bundle

          generate 'devise_invitable:install'
          generate :devise_invitable, 'user'
        end
      end

      def add_routes
        route "devise_for :users, controllers: { registrations: 'users/registrations' }"
      end

      def add_modified_files
        template 'app/controllers/application_controller.rb'
      end
    end
  end
end
