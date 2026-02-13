module Rolemodel
  class ReactGenerator < ApplicationGenerator
    source_root File.expand_path('templates', __dir__)

    def add_npm_packages
      @add_react = yes?('Would you like to add react?')

      if @add_react
        run 'yarn add react react-dom'
      end
    end

    def add_files
      if @add_react
        say 'Copying files'

        template 'app/helpers/react_helper.rb', 'app/helpers/react_helper.rb'

        template 'app/javascript/components/HelloReact.jsx', 'app/javascript/components/HelloReact.jsx'
        template 'app/javascript/controllers/react_controller.js', 'app/javascript/controllers/react_controller.js'
      end
    end

    def import_react_controller
      if @add_react
        say 'Importing react_controller.js'

        append_to_file 'app/javascript/controllers/index.js', <<~JS

          import ReactController from './react_controller.js'
          application.register('react', ReactController)
        JS
      end
    end
  end
end
