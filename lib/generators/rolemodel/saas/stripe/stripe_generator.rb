require_relative '../../../bundler_helpers'

module Rolemodel
  module Saas
    class StripeGenerator < Rails::Generators::Base
      include Rolemodel::BundlerHelpers
      source_root File.expand_path('templates', __dir__)

      def install_stripe
        gem 'stripe'
        run_bundle
      end

      def ask_for_model
        @subscription_needed = yes?('Do you need subscriptions?')
        @registration_needed = yes?('Do you need registrations?')
        if @registration_needed
          while @key_model_name.blank? do
            @key_model_name = ask('What is the key model name that needs registration (eg. events)?')
          end
        end
      end

      def add_routes
        route <<~ROUTES
          resource :organization, only: [:show, :edit, :update] do
            get :oauth, to: 'stripe#organization_oauth'
          end
          resources :organization_invitations, only: [:index, :new, :create]

          namespace :admin do
            resources :subscriptions, only: [:edit, :update]
            resources :organizations, only: [:index, :show]
          end

          resources :#{@key_model_name.pluralize}, except: [:show] do
            member do
              get :details
              get :options
              get :registration_orders
            end
            resources :#{@key_model_name.singularize}_registration_infos, only: :update, as: :registration_infos do
              member do
                patch :update_price
              end
              resources :price_variations, only: %i[create update]
            end

            resource :bank_account, only: [ :edit, :update ]

            collection do
              get :manage, to: '#{@key_model_name.pluralize}#manage'
              get :oauth, to: 'stripe##{@key_model_name.singularize}_oauth'
            end
          end

          scope '#{@key_model_name.pluralize}/:id', controller: :#{@key_model_name.singularize}_registrations do
            get :registration, action: :new, as: :registration_#{@key_model_name.singularize}
            post :registration, action: :create
            post :register_tickets, action: :update_ticket
            delete 'registrations/:itemId', action: :destroy, as: :#{@key_model_name.singularize}_unregister

            get :checkout, action: :checkout, as: :checkout_#{@key_model_name.singularize}
            post :apply_promo_code, as: :apply_promo_code_#{@key_model_name.singularize}
            post :process_payment, action: :process_payment, as: :process_payment_#{@key_model_name.singularize}
          end

          resources :subscriptions, only: [ :new, :create ]
          get 'subscriptions/edit', to: 'subscriptions#edit', as: :edit_subscription # no id needed
          patch 'subscriptions/update', to: 'subscriptions#update', as: :subscription # no id needed
          delete 'subscriptions/cancel', to: 'subscriptions#cancel', as: :cancel_subscription # no id needed
          get 'subscriptions/promotions', to: 'subscriptions#promotions', as: :promotions

          resources :registration_orders, only: [:show, :edit] do
            member do
              post :refund
              post :refund_all
            end

            collection do
              get 'confirmation/:registration_order_ids', action: :confirmation, as: :confirmation
            end
          end

          post '/stripe/webhooks', to: 'stripe#webhooks'

          get '#{@key_model_name.pluralize}/:id', to: '#{@key_model_name.singularize}_registrations#show', as: :show_#{@key_model_name.singularize}

          ROUTES
      end

      def add_models
        if yes?('Would you like to add user invitations?')
          # gem 'devise_invitable'
          # run_bundle

          # generate 'devise_invitable:install'
          # generate :devise_invitable, 'user'
        end
      end

      private

      def add_controllers
      end

      def add_test_files
        copy_file 'app/controllers/application_controller.rb'
        copy_file 'app/controllers/users/registrations_controller.rb'
        copy_file 'app/views/devise'
        copy_file 'spec/controllers/users/registrations_controller_spec.rb'
        copy_file 'spec/support/devise.rb'
        copy_file 'spec/system/users_spec.rb'
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
