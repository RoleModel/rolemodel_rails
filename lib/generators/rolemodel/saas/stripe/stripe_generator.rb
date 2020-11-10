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
        @ticket_needed = @registration_needed && yes?('Do you need tickets?')
        key_model_name = ''
        while key_model_name.blank?
          key_model_name = ask('What is the key model name (eg. event)?')
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
        template 'app/models/model.rb.tt', "app/models/#{@key_model_names[:singular]}.rb"
        if @registration_needed
          template 'app/models/model_registration_info.rb', "app/models/#{@key_model_names[:singular]}_registration_info.rb"
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

      # def add_duplicate_routes
      #   inject_into_file 'config/routes.rb', "resources :infos\n", after: "Rails.application.routes.draw do\n"
      #   inject_into_file 'config/routes.rb', "resources :projects\n", before: 'missing text'
      #   route 'resources :organizations'
      #   route 'resources :users'
      #   route 'resources :organizations'
      #   new_route = <<~ROUTES
      #     resource :organization, only: [:show, :edit, :update] do
      #       get :oauth, to: 'stripe#organization_oauth'
      #     end
      #   ROUTES
      #   route new_route
      #   route 'resources :something_different'
      #   inject_into_file 'config/routes.rb', new_route, after: "Rails.application.routes.draw do\n"
      #   route new_route
      # end

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

      def add_controllers
        copy_file 'app/controllers/admin/organizations_controller.rb'
        copy_file 'app/controllers/admin/subscriptions_controller.rb'
        copy_file 'app/controllers/bank_accounts_controller.rb'
        copy_file 'app/controllers/event_registration_infos_controller.rb'
        copy_file 'app/controllers/event_registrations_controller.rb'
        copy_file 'app/controllers/events_controller.rb'
        copy_file 'app/controllers/organization_invitations_controller.rb'
        copy_file 'app/controllers/organizations_controller.rb'
        copy_file 'app/controllers/price_variations_controller.rb'
        copy_file 'app/controllers/registration_orders_controller.rb'
        copy_file 'app/controllers/stripe_controller.rb'
        copy_file 'app/controllers/subscriptions_controller.rb'
        copy_file 'app/controllers/tickets_controller.rb'
      end

      # items in private have not been completed yet
      private

      def add_views
      end

      def add_services
        copy_file 'app/services/stripe_hooks.rb'
        copy_file 'app/services/stripe_hooks/account.rb'
        copy_file 'app/services/stripe_hooks/base.rb'
        copy_file 'app/services/stripe_hooks/charge.rb'
        copy_file 'app/services/stripe_hooks/customer.rb'
      end

      def add_configuration
        copy_file 'config/initializers/devise.rb'
        copy_file 'config/initializers/filter_parameter_logging.rb'
        copy_file 'config/initializers/payment_gateway.rb'
      end

      def add_database_migrations
      end

      def add_test_files
        copy_file 'spec/services/stripe_hooks/account_spec.rb'
        copy_file 'spec/services/stripe_hooks/charge_spec.rb'
        copy_file 'spec/services/stripe_hooks_spec.rb'
        copy_file 'spec/support/stripe.rb'
        copy_file 'spec/system/admin/organizations_spec.rb'
        copy_file 'spec/system/admin/user_management_spec.rb'
        copy_file 'spec/system/organization_invitations_spec.rb'
        copy_file 'spec/system/organization_management_spec.rb'
        copy_file 'spec/system/register_for_event_spec.rb'
        copy_file 'spec/system/registration_orders_spec.rb'
        copy_file 'spec/system/subscription_management/cancel_subscription_spec.rb'
        copy_file 'spec/system/subscription_management/create_initial_subscription_spec.rb'
        copy_file 'spec/system/subscription_management/upgrade_subscription_spec.rb'
        copy_file 'spec/system/user_management_spec.rb'
      end

      def add_factories
      end

      def modify_existing_files
        inject_into_file 'app/models/user.rb', after: "class User < ApplicationRecord\n" do
          optimize_indentation <<~'RUBY', 2
            #{'has_many :registration_orders' if @registration_needed}
            has_many :user_gateway_ids
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
