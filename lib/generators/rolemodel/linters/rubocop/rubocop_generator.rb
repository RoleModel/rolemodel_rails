# frozen_string_literal: true

module Rolemodel
  module Linters
    # Install the standard rubocop and a custom cop
    class RubocopGenerator < Rails::Generators::Base
      include BundlerHelpers
      source_root File.expand_path('templates', __dir__)

      def install_rubocop
        gem_group :development, :test do
          gem 'rubocop'
          gem 'rubocop-rails'
        end
        run_bundle
      end

      def add_config
        copy_file '.rubocop.yml', force: true
        directory 'lib/cops'
      end
    end
  end
end
