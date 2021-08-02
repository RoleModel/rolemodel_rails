require_relative '../../bundler_helpers'

module Rolemodel
  class TurboGenerator < Rails::Generators::Base
    include Rolemodel::BundlerHelpers
    source_root File.expand_path('templates', __dir__)

    def install_turbo
      gem 'turbo-rails'
      run_bundle

      run 'rails turbo:install'
    end
  end
end
