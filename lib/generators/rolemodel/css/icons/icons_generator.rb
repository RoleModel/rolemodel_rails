module Rolemodel
  module Css
    class IconsGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      def install_css_base
        generate 'rolemodel:css:base' unless File.exists?(Rails.root.join('app/javascript/packs/stylesheet.js'))
      end

      def install_packages
        run 'yarn add svgo'
        run 'yarn add material-icons'
        run 'yarn install'
      end

      def add_view_helper
        copy_file 'app/helpers/icon_helper.rb'
      end

      def add_webpack_loaders
        copy_file 'config/webpack/loaders/custom-icon-loader.js'
        copy_file 'config/webpack/loaders/svg-color-override-loader.js'
      end

      def add_css
        copy_file 'app/javascript/stylesheets/components/icon.scss'
        append_file 'app/javascript/packs/stylesheets.scss', "@import 'stylesheets/components/icon';"
      end

      def add_images_directory
        run 'mkdir app/javascript/images'
      end

      def modify_webpack_environment
        inject_into_file 'config/webpack/environment.js', after: "const { environment } = require('@rails/webpacker')\n" do
          <<~'JS'

            environment.loaders.insert(
              'customIcons',
              {
                test: /\.svg$/,
                use: [{
                  loader: require.resolve('./loaders/custom-icon-loader')
                }],
              },
              { before: 'file' }
            )
          JS
        end
      end

      def modify_application
        inject_into_file 'app/javascript/packs/application.js', after: "ActiveStorage.start()\n" do
          <<~'JS'

            // require custom icons
            require.context("images")
          JS
        end
      end
    end
  end
end
