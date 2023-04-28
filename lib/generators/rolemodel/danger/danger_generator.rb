module Rolemodel
  class DangerGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    def create_base_danger_config
      template 'Dangerfile.erb', 'Dangerfile'
      gem_group :development, :test do
        gem 'danger'
      end
    end

    def create_github_action
      template 'danger.yml', '.github/workflows/danger.yml'
    end

    def create_rubocop_config
      unless File.exist?(Rails.root.join('.rubocop.yml'))
        return unless yes?('Do you want to install rubocop?')
        generate 'rolemodel:linters:rubocop'
      end
      gem_group :development, :test do
        gem 'danger-rubocop'
      end
      template 'rubocop.rb', '.danger/rubocop.rb'
    end

    def create_brakeman_config
      return unless yes?('Do you want to install brakeman?')

      gem_group :development, :test do
        gem 'brakeman'
        gem 'danger-brakeman'
      end
      template 'brakeman.rb', '.danger/brakeman.rb'
    end
  end
end
