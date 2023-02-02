require_relative '../../../bundler_helpers'

module Rolemodel
  module Saas
    class BlazerGenerator < Rails::Generators::Base
      include Rolemodel::BundlerHelpers
      source_root File.expand_path('templates', __dir__)

      def install_blazer
        gem 'sprockets-rails' unless File.readlines('Gemfile').grep(/sprockets/).any?
        gem 'blazer'
        run_bundle

        generate 'blazer:install'
      end

      def add_routes
        return if File.readlines('config/routes.rb').grep(/blazer/).any?

        # add routes for the report controllers
        route_info = "  namespace :reports do\n"
        route_info += "    resources :dashboards, only: %i[index show]\n"
        route_info += "    resources :queries, only: [] do\n"
        route_info += "      post :run, on: :collection\n"
        route_info += "      post :cancel, on: :collection\n"
        route_info += "    end\n"
        route_info += "  end\n"
        route route_info

        # add routes for the Blazer engine
        route_info = "  # authenticate :user, ->(u) { Admin::ReportPolicy.new(u, :report).manage? } do\n"
        route_info += "  mount Blazer::Engine => '/admin/reports', as: :blazer\n"
        route_info += "  # end\n"
        route route_info
      end

      def add_extensions
        copy_file 'config/initializers/blazer.rb'
        copy_file 'lib/blazer_extensions/data_source.rb'
      end

      def add_controllers
        directory 'app/controllers/reports'
      end

      def add_views
        directory 'app/views/reports'
      end

      def add_styles
        copy_file 'app/assets/stylesheets/blazer.css'
        copy_file 'app/assets/stylesheets/selectize.css'
      end

      def add_tests
        copy_file 'spec/factories/blazer_queries.rb'
        copy_file 'spec/system/reporting_spec.rb'
      end

      def add_rake_task
        copy_file 'lib/tasks/reports.rake'
      end
    end
  end
end
