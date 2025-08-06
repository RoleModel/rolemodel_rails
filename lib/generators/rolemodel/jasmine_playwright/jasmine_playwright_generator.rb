module Rolemodel
  class JasminePlaywrightGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    NODE_VERSION = '22.15.0'.freeze

    DEV_DEPENDENCIES = %w[
      @rolemodel/jasmine-playwright-runner
      playwright
      lit-html
    ]

    def ensure_node_version
      say "Establish development environment Node version of #{set_color(NODE_VERSION, :yellow)}", :green

      create_file '.node-version', NODE_VERSION
    end

    def add_npm_packages
      say 'Adding new dev dependency to package.json', :green
      run "yarn add --dev #{DEV_DEPENDENCIES.join(' ')}"
    end

    def add_spec_files
      template 'support/react.mjs', 'spec/javascript/browser/support/react.mjs'
      template 'example_spec.js', 'spec/javascript/browser/example_spec.js'
    end
  end
end
