# frozen_string_literal: true

module Rolemodel
  class SimpleFormGenerator < Rails::Generators::Base
    include BundlerHelpers
    source_root File.expand_path('templates', __dir__)

    def add_gem
      Bundler.with_unbundled_env do
        bundle_command 'add simple_form'
      end
    end

    def add_files
      directory 'app/inputs'
      copy_file 'config/initializers/simple_form.rb'
      copy_file 'config/locales/simple_form.en.yml'

      # Because directory 'lib/templates/slim/scaffold' will try to parse the
      # template files rather than just copy them.
      Pathname.new(self.class.source_root).glob('lib/templates/slim/scaffold/*.tt').each do |tt|
        copy_file tt, tt.relative_path_from(self.class.source_root)
      end
    end
  end
end
