module Rolemodel
  module Css
    class IconsGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

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

      def add_image_directories
        FileUtils.mkdir_p Rails.root.join('app/javascript/images/icons')
      end

      def modify_webpack_environment
        inject_into_file 'config/webpack/environment.js', after: "const { environment } = require('@rails/webpacker')\n" do
          <<~'JS'

            environment.loaders.insert(
              'customIcons',
              {
                test: /\/icons\/.*.svg$/,
                use: [{
                  loader: require.resolve('./loaders/custom-icon-loader')
                }]
              },
              { after: 'file' }
            )
  
            environment.loaders.get('file').exclude = /\/icons\/.*.svg$/
          JS
        end
      end

      def modify_styleguide_with_examples
        copy_file 'app/javascript/images/icons/custom-icon.svg'

        inject_into_file 'app/views/styleguide/index.html.slim' do
          optimize_indentation <<~'slim', 2

            section.card.section--icons.margin-top-xl
              h2.styleguide-section__title Icons
              .flex.justify-around
                div
                  h4 Material Icons
                  .flex.items-center.margin-bottom-sm
                    .margin-right-lg
                      = icon('settings')
                    .code icon('settings')
                  .flex.items-center.margin-bottom-sm
                    .margin-right-lg
                      = icon('delete', color: 'danger')
                    .code icon('delete', color: danger)
                  .flex.items-center.margin-bottom-sm
                    .margin-right-lg
                      = icon('info', color: 'primary', classes: 'icon--lg')
                    .code icon('info', color: 'primary', classes: 'icon--lg')
                div
                  h4 Custom Icons
                  .flex.items-center.margin-bottom-sm
                    span Located in
                    .code.margin-left-sm app/javascript/images/icons
                  .flex.items-center.margin-bottom-sm
                    .margin-right-lg
                      = icon('custom-icon')
                    .code icon('custom-icon')
          slim
        end

        inject_into_file 'app/javascript/stylesheets/styleguide.scss' do
          <<~'slim'

            .section--icons {
              h4 {
                text-transform: none;
                font-weight: bold;
              }
            
              .code {
                font-family: monospace;
                background: var(--color-neutral-50);
                border-radius: var(--radius-sm);
                word-wrap: break-word;
                padding: 0.4rem 0.3rem;
              }
            }
          slim
        end
      end

      def require_images
        inject_into_file 'app/javascript/packs/application.js', after: "ActiveStorage.start()\n" do
          <<~'JS'

            // require custom icons
            require.context('images/icons', true)
          JS
        end
      end
    end
  end
end
