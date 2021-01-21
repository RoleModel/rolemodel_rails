require_relative '../../../bundler_helpers'

module Rolemodel
  module Saas
    class DeviseGenerator < Rails::Generators::Base
      include Rolemodel::BundlerHelpers
      source_root File.expand_path('templates', __dir__)

      def add_organization
        generate :model, 'organization name:string' unless File.exist?(Rails.root.join('app/models/organization.rb'))
        inject_into_file 'app/models/organization.rb', "  has_many :users, inverse_of: :organization\n", after: "ApplicationRecord\n"
      end

      def install_devise
        gem 'devise'
        run_bundle

        generate 'devise:install'
        generate :devise, 'user first_name:string last_name:string'
        generate :migration, 'add_organization_and_role_to_users organization_id:bigint:index role:string super_admin:boolean'
        file_name = Dir.glob(Rails.root.join('db/migrate', '*_add_organization_and_role_to_users.rb', )).last
        gsub_file file_name, /:role, :string$/, ":role, :string, default: 'user', null: false"
        gsub_file file_name, /:super_admin, :boolean$/, ':super_admin, :boolean, default: false, null: false'
      end

      def add_invitable
        @add_invitations = yes?('Would you like to add user invitations?')
        if @add_invitations
          gem 'devise_invitable'
          run_bundle

          generate 'devise_invitable:install'
          generate :devise_invitable, 'user'
        end
      end

      def add_routes
        route_info = ", controllers: {\n"
        route_info += "    invitations: 'users/invitations',\n" if @add_invitations
        route_info += "    registrations: 'users/registrations',\n"
        route_info += "  }"
        inject_into_file 'config/routes.rb', route_info, after: /devise_for :users$/
      end

      def add_modified_files
        copy_file 'app/controllers/application_controller.rb'
        if @add_invitations
          copy_file 'app/controllers/users/invitations_controller.rb'
          directory 'app/views/devise/invitations'
          copy_file 'app/views/devise/mailer/invitation_instructions.html.slim'
          copy_file 'app/views/devise/mailer/invitation_instructions.text.slim'
          copy_file 'config/locales/devise_invitable.en.yml'
        end
        copy_file 'app/controllers/users/registrations_controller.rb'
        directory 'app/views/devise', exclude_pattern: /invitation/
        copy_file 'config/locales/devise.en.yml'
        copy_file 'spec/support/devise.rb'
        copy_file 'spec/system/users_spec.rb'
        copy_file 'spec/factories/organizations.rb'
        copy_file 'spec/factories/users.rb'
      end

      def modify_existing_files
        inject_into_file 'config/environments/development.rb', after: "config.action_mailer.perform_caching = false\n" do
          optimize_indentation <<~'RUBY', 2

            # Default mailing host suggested by Devise installation instructions
            config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
          RUBY
        end

        inject_into_file 'config/environments/production.rb', after: "config.action_mailer.perform_caching = false\n" do
          optimize_indentation <<~'RUBY', 2

            # Tell Devise about your host, so it can send password reset emails
            if ENV['REVIEW_APP'] == 'true' && ENV['HEROKU_APP_NAME'].present?
              config.action_mailer.default_url_options = { host: "https://#{ENV['HEROKU_APP_NAME']}.herokuapp.com" }
            else
              config.action_mailer.default_url_options = { host: ENV['PRODUCTION_HOST'] }
            end
          RUBY
        end

        # Update Devise email_regexp to something more useful
        gsub_file 'config/initializers/devise.rb', '/\A[^@\s]+@[^@\s]+\z/', '/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i'
        # Turn Devise validate_on_invite on by default
        if @add_invitations
          gsub_file 'config/initializers/devise.rb', '# config.validate_on_invite = true', 'config.validate_on_invite = true'
        end

        inject_into_file 'app/models/user.rb', after: /devise\s+:.*\n.*\n/ do
          optimize_indentation <<~'RUBY', 2

            enum role: { user: 'user', admin: 'admin' }

            belongs_to :organization, inverse_of: :users
            accepts_nested_attributes_for :organization

            validates :first_name, :last_name, :role, presence: true
            delegate :name, to: :organization, prefix: true
          RUBY
        end

        inject_into_file 'db/seeds.rb', after: "Examples:\n" do
          <<~'RUBY'
            if Rails.env.development?
              puts 'Creating the default user environment...'

              organization = Organization.create!(
                name: 'RoleModel Software'
              )

              User.create!(
                first_name: 'Support',
                last_name: 'Admin',
                organization: organization,
                super_admin: true,
                role: User.roles[:admin],
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
