require_relative '../../../bundler_helpers'

module Rolemodel
  module Css
    class BaseGenerator < Rails::Generators::Base
      include Rolemodel::BundlerHelpers
      source_root File.expand_path('templates', __dir__)

      def install_webpack
        generate 'rolemodel:webpacker'
      end

      def add_slim
        gem 'slim'
        run_bundle
      end

      def remove_application_erb_file
        remove_file 'app/views/layouts/application.html.erb'
      end

      def copy_css_templates
        # TODO: remove parent_name when no longer using Rails 5
        @project_name = Rails.application.class.try(:parent_name) || Rails.application.class.module_parent_name
        files = Dir.glob(Pathname(Rolemodel::Css::BaseGenerator.source_root).join('**', '*'))
        files.each do |file|
          next if File.directory?(file)

          source = file.sub(Rolemodel::Css::BaseGenerator.source_root + '/', '')
          destination = file.sub(Rolemodel::Css::BaseGenerator.source_root + '/', '')
          copy_file source, destination
        end
      end

      def add_styleguide_route
        route "get '/styleguide', to: 'styleguide#index'"
      end

      def use_webpacker_styles_in_layout
        layouts = [ 'erb', 'slim' ].each do |template_language|
          layout_file = "app/views/layouts/application.html.#{template_language}"

          next unless File.exists? layout_file
          gsub_file layout_file, "stylesheet_link_tag 'application', media: 'all'", "stylesheet_pack_tag 'stylesheets'"
        end
      end
    end
  end
end
