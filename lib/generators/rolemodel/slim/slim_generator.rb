# frozen_string_literal: true

module Rolemodel
  class SlimGenerator < Rails::Generators::Base
    include BundlerHelpers
    source_root File.expand_path('templates', __dir__)

    def add_slim
      bundle_command 'add slim'
    end

    def add_slim_rails
      bundle_command 'add slim-rails'
    end

    def replace_erb_layout
      remove_file 'app/views/layouts/application.html.erb'
      template 'app/views/layouts/application.html.slim'
    end

    def copy_templates
      # Because directory 'lib/templates/slim/scaffold' will try to parse the
      # template files rather than just copy them.
      Pathname.new(self.class.source_root).glob('lib/templates/slim/scaffold/*.tt').each do |tt|
        copy_file tt, tt.relative_path_from(self.class.source_root)
      end
    end

    protected

    def available_views
      %w[index edit show new _form]
    end
  end
end
