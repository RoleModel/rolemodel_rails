require_relative '../../../bundler_helpers'

module Rolemodel
  module Testing
    class RspecGenerator < Rails::Generators::Base
      include Rolemodel::BundlerHelpers
      source_root File.expand_path('templates', __dir__)

      def install_rspec
        gem_group :development, :test do
          gem 'rspec-rails'
        end
        run_bundle

        gem_group :test do
          gem 'capybara'
          gem 'webdrivers'
        end
        run_bundle
      end

      def add_spec_files
        template 'rails_helper.rb', 'spec/rails_helper.rb'
        template 'spec_helper.rb', 'spec/spec_helper.rb'
        template '.rspec', '.rspec'
        template 'support/capybara_drivers.rb', 'spec/support/capybara_drivers.rb'
        template 'support/helpers.rb', 'spec/support/helpers.rb'
        append_file '.gitignore', 'spec/examples.txt'
      end
    end
  end
end
