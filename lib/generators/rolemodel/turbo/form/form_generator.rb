module Rolemodel
  module Turbo
    class FormGenerator < GeneratorBase
      def install_turbo_form
        say 'Installing turbo_form', :green

        Bundler.with_unbundled_env do
          bundle_command 'add turbo_form'
        end

        generate 'turbo_form:install'
      end

      def install_agent_skill
        say 'Installing the dynamic-forms agent skill', :green

        install_skill 'dynamic-forms'
      end
    end
  end
end
