module Rolemodel
  class JasminePlaywrightGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    DEV_DEPENDENCIES = %w[
      @rolemodel/jasmine-playwright-runner
      playwright
    ]

    def add_npm_packages
      say 'Adding new dev dependency to package.json', :green
      run "yarn add --dev #{DEV_DEPENDENCIES.join(' ')}"
    end
  end
end
