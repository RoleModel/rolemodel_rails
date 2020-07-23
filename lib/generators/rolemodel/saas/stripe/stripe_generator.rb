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
        @ticket_needed = yes?('Do you need tickets?')
        key_model_name = ''
        while key_model_name.blank?
          key_model_name = ask('What is the key model name (eg. events)?')
        end
        @key_model_names = {
          klass: key_model_name.classify.singularize,
          klass_plural: key_model_name.classify.pluralize,
          singular: key_model_name.underscore.singularize,
          plural: key_model_name.underscore.pluralize
        }
      end

      def add_models
        copy_file 'app/models/bank_account.rb'
        template 'app/models/event.rb.tt', "app/models/#{@key_model_names[:singular]}.rb"
        if @registration_needed
          template 'app/models/event_registration_info.rb', "app/models/#{@key_model_names[:singular]}_registration_info.rb"
          template 'app/models/price_variation.rb'
          template 'app/models/promotional_code.rb'
          template 'app/models/registration_item.rb'
          template 'app/models/registration_order.rb'
          copy_file 'app/models/registration_pricing.rb'
          template 'app/models/refund.rb'
        end
        if @subscription_needed
          copy_file 'app/models/subscription.rb'
          copy_file 'app/models/subscription/null.rb'
          copy_file 'app/models/subscription/stripe.rb'
          copy_file 'app/models/subscription_description.rb'
          copy_file 'app/models/subscription_plan.rb'
          copy_file 'app/models/subscription_plan/organization.rb'
          copy_file 'app/models/subscription_plan/individual.rb'
          copy_file 'app/models/subscription_plan/participant.rb'
          copy_file 'app/models/subscription_plan/registration.rb'
        end
        if @ticket_needed
          template 'app/models/ticket.rb.tt'
          copy_file 'app/models/ticket_item.rb'
        end
        template 'app/models/payment_source.rb'
        template 'app/models/organization.rb'
        copy_file 'app/models/user_gateway_id.rb'
      end

      # adding in reverse order since it adds to the top of the file
      def add_routes
        if @registration_needed
          route %Q|get '#{@key_model_names[:plural]}/:id', to: '#{@key_model_names[:singular]}_registrations#show', as: :show_#{@key_model_names[:singular]}|
        end
        route "post '/stripe/webhooks', to: 'stripe#webhooks'"
        if @registration_needed
          route <<~'ROUTES'
            resources :registration_orders, only: [:show, :edit] do
              member do
                post :refund
                post :refund_all
              end

              collection do
                get 'confirmation/:registration_order_ids', action: :confirmation, as: :confirmation
              end
            end
          ROUTES
        end

        if @subscription_needed
          route "get 'subscriptions/promotions', to: 'subscriptions#promotions', as: :promotions"
          route "delete 'subscriptions/cancel', to: 'subscriptions#cancel', as: :cancel_subscription # no id needed"
          route "patch 'subscriptions/update', to: 'subscriptions#update', as: :subscription # no id needed"
          route "get 'subscriptions/edit', to: 'subscriptions#edit', as: :edit_subscription # no id needed"
          route 'resources :subscriptions, only: [ :new, :create ]'
        end

        if @registration_needed
          route <<~ROUTES
            scope '#{@key_model_names[:plural]}/:id', controller: :#{@key_model_names[:singular]}_registrations do
              get :registration, action: :new, as: :registration_#{@key_model_names[:singular]}
              post :registration, action: :create
              post :register_tickets, action: :update_ticket
              delete 'registrations/:itemId', action: :destroy, as: :#{@key_model_names[:singular]}_unregister

              get :checkout, action: :checkout, as: :checkout_#{@key_model_names[:singular]}
              post :apply_promo_code, as: :apply_promo_code_#{@key_model_names[:singular]}
              post :process_payment, action: :process_payment, as: :process_payment_#{@key_model_names[:singular]}
            end
          ROUTES
        end

        # intentionally indented an extra level to make the output match in the routes.rb file
        registration_infos_routes = <<~ROUTE
          resources :#{@key_model_names[:singular]}_registration_infos, only: :update, as: :registration_infos do
              member do
                patch :update_price
              end
              resources :price_variations, only: %i[create update]
            end
        ROUTE

        route <<~ROUTES
          resources :#{@key_model_names[:plural]}, except: [:show] do
            member do
              get :details
              get :options#{"\n    get :registration_orders" if @registration_needed}
            end
            #{registration_infos_routes if @registration_needed}
            resource :bank_account, only: [ :edit, :update ]

            collection do
              get :manage, to: '#{@key_model_names[:plural]}#manage'
              get :oauth, to: 'stripe##{@key_model_names[:singular]}_oauth'
            end
          end
        ROUTES

        route <<~ROUTES
          namespace :admin do
            #{"resources :subscriptions, only: [:edit, :update]\n  " if @subscription_needed}resources :organizations, only: [:index, :show]
          end
        ROUTES

        route 'resources :organization_invitations, only: [:index, :new, :create]'
        route <<~'ROUTES'
          resource :organization, only: [:show, :edit, :update] do
            get :oauth, to: 'stripe#organization_oauth'
          end
        ROUTES
      end

      private

      def add_controllers
      end

      private
      def add_services
      end

      def add_configuration
      end

      def add_test_files
        copy_file 'app/controllers/application_controller.rb'
        copy_file 'app/controllers/users/registrations_controller.rb'
        copy_file 'app/views/devise'
        copy_file 'spec/controllers/users/registrations_controller_spec.rb'
        copy_file 'spec/support/devise.rb'
        copy_file 'spec/system/users_spec.rb'
      end

      def add_factories
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
