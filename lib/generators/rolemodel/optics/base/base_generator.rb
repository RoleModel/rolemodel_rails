module Rolemodel
  module Optics
    class BaseGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      def add_optics_package
        run 'yarn add @rolemodel/optics'
      end

      def add_slim
        generate 'rolemodel:slim'
      end

      def remove_application_erb_file
        remove_file 'app/views/layouts/application.html.erb'
      end

      def copy_templates
        @project_name = Rails.application.class.module_parent_name
        files = Dir.glob(Pathname(Rolemodel::Optics::BaseGenerator.source_root).join('**', '*'))
        files.each do |file|
          next if File.directory?(file)

          source = file.sub(Rolemodel::Optics::BaseGenerator.source_root + '/', '')
          destination = file.sub(Rolemodel::Optics::BaseGenerator.source_root + '/', '')
          copy_file source, destination
        end
      end
    end
  end
end
