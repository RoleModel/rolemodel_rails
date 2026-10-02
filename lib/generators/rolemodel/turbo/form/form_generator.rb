module Rolemodel
  module Turbo
    class FormGenerator < GeneratorBase
      def install_turbo_form
        say 'Installing turbo_form', :green

        bundle_command 'add turbo_form'

        generate 'turbo_form:install'
      end

      def install_agent_skill
        say 'Installing the dynamic-forms agent skill', :green

        install_skill 'dynamic-forms'
      end
    end
  end
end
