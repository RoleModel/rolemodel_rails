# frozen_string_literal: true

require_relative '../../../bundler_helpers'

module Rolemodel
  module Linters
    # Install Standard rubocop and custom Cop
    class RubocopGenerator < Rails::Generators::Base
      include Rolemodel::BundlerHelpers
      source_root File.expand_path('templates', __dir__)

      def install_rubocop
        gem_group :development, :test do
          gem 'rubocop'
          gem 'rubocop-rails'
        end
        run_bundle
      end

      def add_config
        copy_file '.rubocop.yml'
        copy_file 'app/cops/form_error_response.rb'
      end
    end
  end
end
