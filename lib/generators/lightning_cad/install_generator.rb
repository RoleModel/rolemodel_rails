require 'rails'

module LightningCad
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      source_root File.expand_path('./templates', __dir__)

      def install_lightning_cad
        say 'Adding lightning-cad dependency'
        run('yarn add git+ssh://git@github.com/RoleModel/lightning-cad.git#master')
      end

      def install_yarn_dependencies
        say 'Adding additional javascript dependencies'

        dependencies = %w[
          @babel/preset-env@7.21.4
          @babel/preset-react@7.18.6
          @babel/plugin-syntax-jsx@7.21.4
          @babel/core@7.21.4
          mobx-react@^6.1.5
          mobx-utils@^5.5.2
          mobx@^5.15.2
          glob@^10.2.2
          react@16.9.0
          react-dom@16.9.0
          import-glob@1.5.0
          react-router-dom@^5.0.1
          react-popper@^1.3.7
        ]
        run("yarn add #{dependencies.join(" ")}")
      end

      def install_yarn_dev_dependencies
        say 'Adding javascript devDependencies'

        dev_dependencies = %w[
          @testing-library/jest-dom@^5.16.5
          @testing-library/react@^12.1.2
          @testing-library/user-event@^13.1.8
          fetch-mock@^9.11.0
          jasmine@^4.6.0
          jest@^29.5.0
          babel-jest@^29.5.0
        ]
        run("yarn add --dev #{dev_dependencies.join(" ")}")
      end

      def install_yarn_optional_dependencies
        say 'Adding optional dependencies'
        say "THREE.js packages are not required if this project does not implement 3D views"
        run("yarn add --optional three@^0.144.0")
      end

      def remove_unused_js
        hello_controller = "\nimport HelloController from './hello_controller.js'\napplication.register('hello', HelloController)\n"
        gsub_file 'app/javascript/controllers/index.js', hello_controller, ''

        remove_file 'app/javascript/packs/hello_react.jsx'
        remove_file 'app/javascript/controllers/hello_controller.js'
      end

      def add_yarn_tasks
        say 'Adding package.json test scripts'

        yarn_scripts = <<-'JS'
    "test": "bundle exec rake javascript_tests",
    "test_view": "NODE_ENV=test yarn node --experimental-vm-modules $(yarn bin jest --watch)",
    "test_view_ci": "NODE_ENV=test yarn node --experimental-vm-modules $(yarn bin jest)",
    "test_shared": "NODE_ENV=test NODE_PATH=\"./node_modules:./app/javascript:$NODE_PATH\" jasmine",
    "build": "webpack --config webpack.config.js",
        JS
        inject_into_file 'package.json', yarn_scripts, before: "  \"eslint\": \"eslint"
      end

      def add_jest_config
        say 'Adding jest config'
        copy_file 'jest.config.js', 'jest.config.js'
      end

      def add_webpack_config
        say 'Adding webpack config'
        copy_file 'webpack.config.js', 'webpack.config.js'
      end

      def setup_javascript_specs
        say "Set up jest/jasmine environment and basic test harness"

        copy_file 'lib/tasks/javascript_tests.rake', 'lib/tasks/javascript_tests.rake'

        copy_file 'spec/javascript/components/.eslintrc.js', 'spec/javascript/components/.eslintrc.js'
        copy_file 'spec/javascript/components/TestSetup.js', 'spec/javascript/components/TestSetup.js'
        copy_file 'spec/javascript/components/__mocks__/FilePathMock.js', 'spec/javascript/components/__mocks__/FilePathMock.js'
        copy_file 'spec/javascript/components/support/matchMedia.js', 'spec/javascript/components/support/matchMedia.js'
        copy_file 'babel.config.cjs', 'babel.config.cjs'

        copy_file 'spec/javascript/shared/.eslintrc.js', 'spec/javascript/shared/.eslintrc.js'
        copy_file 'spec/javascript/shared/TestSetup.js', 'spec/javascript/shared/TestSetup.js'

        copy_file 'spec/javascript/shared/testSpec.js', 'spec/javascript/shared/testSpec.js'

        copy_file 'spec/support/jasmine.json', 'spec/support/jasmine.json'
      end

      def create_basic_app
        say "Creating React App Component"
        copy_file 'app/javascript/controllers/react_controller.js', 'app/javascript/controllers/react_controller.js'
        copy_file 'app/javascript/components/MaterialIcon.jsx', 'app/javascript/components/MaterialIcon.jsx'
        copy_file 'app/javascript/components/LocalIconFactory.jsx', 'app/javascript/components/LocalIconFactory.jsx'
        copy_file 'app/javascript/components/App.jsx', 'app/javascript/components/App.jsx'
        copy_file 'spec/javascript/components/AppSpec.jsx', 'spec/javascript/components/AppSpec.jsx'
      end

      def add_stylesheets
        stylesheets = <<-CSS
          @import '@rolemodel/lightning-cad/drawing-editor-react/stylesheets/MultiPerspectiveProjectEditorView.scss';

          .canvas-area {
            height: calc(100vh - $header-height);
          }

          body, html {
            margin: 0
          }
        CSS

        append_to_file 'app/assets/stylesheets/application.scss', stylesheets
      end

      def global_configuration
        copy_file '.eslintrc.js', '.eslintrc.js'
      end

      def create_controller
        say "Creating Rails controller and view"
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
        copy_file 'spec/javascript/helpers/initializers.js', 'spec/javascript/helpers/initializers.js'
        # To prevent smartJSON from throwing an error
        run 'mkdir app/javascript/shared'
        run 'mkdir app/javascript/shared/domain-models'
        run 'touch app/javascript/shared/domain-models/.keep'
      end
    end
  end
end
