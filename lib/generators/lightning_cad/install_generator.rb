require 'rails'

module LightningCad
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('./templates', __dir__)

    def install_yarn_dependencies
      say 'Adding lightning-cad dependency'
      copy_file '.npmrc', '.npmrc'

      dependencies = %w[
        @rolemodel/lightning-cad
        @rolemodel/lightning-cad-ui
        glob
        import-glob
      ]

      run "yarn add #{dependencies.join(" ")}"
    end

    def add_webpack_config
      say 'Adding webpack config'
      copy_file 'webpack.config.js', 'webpack.config.js'
    end

    def create_basic_app
      say "Creating React App Component"
      copy_file 'app/javascript/controllers/react_controller.js', 'app/javascript/controllers/react_controller.js'
      copy_file 'app/javascript/components/MaterialIcon.jsx', 'app/javascript/components/MaterialIcon.jsx'
      copy_file 'app/javascript/components/LocalIconFactory.jsx', 'app/javascript/components/LocalIconFactory.jsx'
      copy_file 'app/javascript/components/App.jsx', 'app/javascript/components/App.jsx'
    end

    def add_stylesheets
      stylesheets = <<~CSS
        @import '@rolemodel/lightning-cad-ui/scss/lightning-cad.scss';
      CSS

      prepend_to_file 'app/assets/stylesheets/application.scss', stylesheets
    end

    def global_configuration
      copy_file '.eslintrc.js', '.eslintrc.js'
    end

    def create_controller
      say "Creating Rails controller and view"
      template 'app/views/layouts/editor.html.slim'
      copy_file 'app/controllers/editor_controller.rb', 'app/controllers/editor_controller.rb'
      copy_file 'app/views/editor/editor.html.slim', 'app/views/editor/editor.html.slim'
      route "get '/editor/*all', to: 'editor#editor'"
      route "get :editor, to: 'editor#editor'"
    end

    def add_javascript_initializers
      say "Adding JavaScript initializers"
      initializer_setup = <<~JS
        import './config/initializers/**/*.js'
      JS
      append_to_file 'app/javascript/application.js', initializer_setup
      copy_file 'app/javascript/config/initializers/smartJSON.js', 'app/javascript/config/initializers/smartJSON.js'
      # To prevent smartJSON from throwing an error
      run 'mkdir app/javascript/shared'
      run 'mkdir app/javascript/shared/domain-models'
      run 'touch app/javascript/shared/domain-models/.keep'
    end
  end
end
