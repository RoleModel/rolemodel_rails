module Rolemodel
  module Testing
    class FactoryBotGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      def install_factory_bot_rails
        gem_group :development, :test do
          gem 'factory_bot_rails'
        end
      end

      def add_spec_files
        template 'support/factory_bot.rb', 'spec/support/factory_bot.rb'
      end
    end
  end
end
