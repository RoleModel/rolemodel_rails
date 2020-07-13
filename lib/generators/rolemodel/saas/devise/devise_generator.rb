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
        template 'app/controllers/users/registrations_controller.rb'
        template 'app/views/devise'
        template 'spec/controllers/users/registrations_controller_spec.rb'
        template 'spec/support/devise.rb'
        template 'spec/system/users_spec.rb'
      end

      def modify_existing_files
        inject_into_file 'config/environments/development.rb', after: "config.action_mailer.perform_caching = false\n" do <<-'RUBY'

          # Default mailing host suggested by Devise installation instructions
          config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
        RUBY
        end

        inject_into_file 'config/environments/production.rb', after: "config.action_mailer.perform_caching = false\n" do <<-'RUBY'

          # Tell Devise about your host, so it can send password reset emails
          if ENV['REVIEW_APP'] == 'true' && ENV['HEROKU_APP_NAME'].present?
            config.action_mailer.default_url_options = { host: "https://#{ENV['HEROKU_APP_NAME']}.herokuapp.com" }
          else
            config.action_mailer.default_url_options = { host: ENV['PRODUCTION_HOST'] }
          end
        RUBY
        end

        inject_into_file 'app/models/user.rb', after: "class User < ApplicationRecord\n" do <<-'RUBY'
          ROLES = %w[support_admin org_admin user]

          belongs_to :organization, inverse_of: :users
          accepts_nested_attributes_for :organization

          VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
          validates :first_name, :last_name, :organization, :email, presence: true
          validates :email, uniqueness: true, format: { with: VALID_EMAIL_REGEX }
          validates :role, inclusion: { in: ROLES }
          delegate :name, to: :organization, prefix: true

          def org_admin?
            role == 'org_admin'
          end
          def support_admin?
            role == 'support_admin'
          end
        RUBY
        end

        inject_into_file 'db/seeds.rb', after: "Examples:\n" do <<-'RUBY'
          if Rails.env.development?
            puts 'Creating the default user environment...'
         
            organization = Organization.create!(
              name: 'RoleModel Software'
            )
         
            User.create!(
              first_name: 'Support',
              last_name: 'Admin',
              organization: organization,
              role: 'support_admin',
              email: 'user@example.com',
              password: 'password',
              password_confirmation: 'password'
            )
          end
        RUBY
        end
      end
    end
  end
end
