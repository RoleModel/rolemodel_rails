module Rolemodel
  module Turbo
    class ConfirmGenerator < ::Rolemodel::GeneratorBase
      source_root File.expand_path('templates', __dir__)

      def add_turbo_confirm_package
        say 'Installing Turbo Confirm package', :green

        yarn_command 'add @rolemodel/turbo-confirm'
      end

      def add_initializer
        template 'app/javascript/initializers/turbo_confirm.js'

        append_to_file 'app/javascript/application.js' do
          optimize_indentation <<~JS
            import './initializers/turbo_confirm.js'
          JS
        end
      end

      def add_view_partial
        template 'app/views/application/_confirm.html.slim'

        inject_into_file 'app/views/layouts/application.html.slim', after: /\bbody.*\n/ do
          optimize_indentation <<~SLIM, 4
            = render 'confirm'
          SLIM
        end
      end
    end
  end
end

