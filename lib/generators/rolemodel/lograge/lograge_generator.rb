# frozen_string_literal: true

require_relative '../../bundler_helpers'

module Rolemodel
  class LogrageGenerator < Rails::Generators::Base
    include Rolemodel::BundlerHelpers
    source_root File.expand_path('templates', __dir__)

    def install_lograge
      bundle_command 'add lograge'
    end

    def add_lograge_config
      copy_file 'config/initializers/lograge.rb'
    end
  end
end
