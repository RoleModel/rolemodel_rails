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

    def add_react_rails_ujs_event_handlers
      addendum = File.read([source_paths.last, '/application_addendum.js'].join)
      append_to_file 'app/javascript/packs/application.js', addendum
    end
  end
end
