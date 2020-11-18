require_relative '../../../bundler_helpers'

module Rolemodel
  module Linters
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
        template '.rubocop.yml', '.rubocop.yml'
      end
    end
  end
end
