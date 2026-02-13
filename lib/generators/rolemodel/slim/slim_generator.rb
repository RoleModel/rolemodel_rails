# frozen_string_literal: true

module Rolemodel
  class SlimGenerator < ApplicationGenerator
    source_root File.expand_path('templates', __dir__)

    def add_slim
      bundle_command 'add slim'
    end

    def add_slim_rails
      bundle_command 'add slim-rails'
    end

    def remove_erb_layout
      remove_file 'app/views/layouts/application.html.erb'
    end

    def copy_templates
      directory 'app/views'
      directory 'lib/templates/slim/scaffold'
    end
  end
end
