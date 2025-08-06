module Rolemodel
  class JasminePlaywrightGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    NODE_VERSION = '22.15.0'.freeze

    DEV_DEPENDENCIES = %w[
      @rolemodel/jasmine-playwright-runner
      playwright
      lit-html
    ]

    def add_jasmine_playwright_script
      package_json_path = Rails.root.join('package.json')
      command = 'NODE_ENV=test jp-runner --config jp-runner.config.mjs --webpack-config webpack.config.cjs'

      if File.exist?(package_json_path)
        package_json = JSON.parse(File.read(package_json_path))
        package_json['scripts'] ||= {}
        package_json['scripts']['test:browser'] = command
        File.write(package_json_path, JSON.generate(package_json))
        say 'Added jasmine:playwright script to package.json', :green
      else
        say 'package.json not found. Please run yarn init first.', :red
      end
    end

    def ensure_node_version
      say "Establish development environment Node version of #{set_color(NODE_VERSION, :yellow)}", :green

      create_file '.node-version', NODE_VERSION
    end

    def add_npm_packages
      say 'Adding new dev dependency to package.json', :green
      run "yarn add --dev #{DEV_DEPENDENCIES.join(' ')}"
    end

    def add_spec_files
      template 'example_spec.js', 'spec/javascript/browser/example_spec.js'
      template 'jp-runner.config.mjs', 'jp-runner.config.mjs'
      template 'setupTests.js', 'spec/javascript/browser/setupTests.js'
    end
  end
end
