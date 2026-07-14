module Rolemodel
  module Turbo
    class InstallGenerator < ::Rolemodel::GeneratorBase
      source_root File.expand_path('templates', __dir__)

      def add_turbo
        bundle_command 'add turbo-rails'
      end

      def add_stimulus
        bundle_command 'add stimulus-rails'
      end

      def install_turbo
        rails_command 'turbo:install'
      end

      def install_stimulus
        rails_command 'stimulus:install'
      end
    end
  end
end

