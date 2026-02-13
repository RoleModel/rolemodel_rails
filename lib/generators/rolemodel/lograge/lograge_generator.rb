# frozen_string_literal: true

module Rolemodel
  class LogrageGenerator < ApplicationGenerator
    source_root File.expand_path('templates', __dir__)

    def install_lograge
      bundle_command 'add lograge'
    end

    def add_lograge_config
      copy_file 'config/initializers/lograge.rb'
    end
  end
end
