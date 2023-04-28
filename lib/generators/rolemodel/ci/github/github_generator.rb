module Rolemodel
  module CI
    class GithubGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      def create_base_github_config
        template 'rspec.yml', '.github/workflows/rspec.yml'
        template 'rspec.yml', '.github/workflows/jest.yml' if File.exists?(Rails.root.join('package.json'))
      end
    end
  end
end