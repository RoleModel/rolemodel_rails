module Rolemodel
  module Turbo
    class FormGenerator < GeneratorBase
      def install_turbo_form
        say 'Installing turbo_form', :green

        bundle_command 'add turbo_form'

        generate 'turbo_form:install'
      end
    end
  end
end
