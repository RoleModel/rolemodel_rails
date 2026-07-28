# frozen_string_literal: true

module Rolemodel
  module UiComponents
    class NavbarGenerator < GeneratorBase
      source_root File.expand_path('templates', __dir__)

      def copy_navbar_files
        say 'Copying Navbar files', :green

        directory 'app/views'
      end

      def insert_navbar_before_content
        say 'Inserting Navbar render tag', :green

        insert_into_file 'app/views/layouts/application.html.slim', before: /\s+\.app__content/ do
          optimize_indentation <<~SLIM, 4

            = render 'navbar'
          SLIM
        end
      end

      def install_shoelace
        say 'Installing Shoelace package', :green

        yarn_command 'add @shoelace-style/shoelace'
      end

      def add_shoelace_javascript_imports
        say 'Copying Shoelace JS imports', :green

        directory 'app/javascript/lib'
        append_to_file 'app/javascript/application.js', <<~JS
          import './lib/shoelace.js'
        JS
      end

      def copy_shoelace_css_imports
        say 'Copying Shoelace CSS imports', :green

        copy_file 'app/assets/stylesheets/components/shoelace/index.css'
        append_to_file application_stylesheet_path, <<~CSS
          @import 'components/shoelace/index.css';
        CSS
      end
    end
  end
end
