# frozen_string_literal: true

module Rolemodel
  module UiComponents
    class NavbarGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      def copy_navbar_files
        say 'Copying Navbar files', :green

        copy_file 'app/views/layouts/_navbar.html.slim'

        insert_into_file 'app/views/layouts/application.html.slim', after: /\bbody.*\n/ do
          optimize_indentation <<~SLIM, 4
            = render 'layouts/navbar'
          SLIM
        end
      end

      def install_shoelace
        say 'Installing Shoelace package', :green

        run 'yarn add @shoelace-style/shoelace'
      end

      def add_shoelace_javascript_imports
        say 'Copying Shoelace JS imports', :green

        copy_file 'app/javascript/lib/shoelace.js'
        append_to_file 'app/javascript/application.js' do
          <<~JS
            import './lib/shoelace.js'
          JS
        end
      end

      def copy_shoelace_css_imports
        say 'Copying Shoelace CSS imports', :green

        copy_file 'app/assets/stylesheets/components/shoelace/index.scss'
        append_to_file 'app/assets/stylesheets/application.scss' do
          <<~SCSS
            @import 'components/shoelace/index.scss';
          SCSS
        end
      end
    end
  end
end
