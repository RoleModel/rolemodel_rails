require_relative '../../bundler_helpers'

module Rolemodel
  class SlimGenerator < Rails::Generators::Base
    include Rolemodel::BundlerHelpers

    source_root File.expand_path('templates', __dir__)

    def add_slim
      bundle_command 'add slim'
    end

    def replace_erb_layout
      remove_file 'app/views/layouts/application.html.erb'
      template 'app/views/layouts/application.html.slim'
    end
  end
end
