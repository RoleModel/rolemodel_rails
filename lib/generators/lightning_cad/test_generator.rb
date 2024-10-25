require 'rails'

module LightningCad
  class TestGenerator < Rails::Generators::Base
    source_root File.expand_path('./templates', __dir__)

    def add_jasmine_tests
      say 'Adding jasmine'
      run "yarn add --dev jasmine@^5.1.0 @rolemodel/jasmine-playwright-runner @testing-library/react"

      run 'npm pkg set scripts.test:server="NODE_OPTIONS=\'--import=./app/javascript/helpers/register_hooks.js\' jasmine --config=jasmine.json"'
      run 'npm pkg set scripts.test:browser="NODE_ENV=test jp-runner"'
      run 'npm pkg set scripts.test="yarn test:server && yarn test:browser"'

      copy_file 'jasmine.json'
      copy_file 'jp-runner.config.json'
      copy_file 'spec/javascript/.eslintrc.js'
      copy_file 'spec/javascript/shared/TestSetup.js'
      copy_file 'spec/javascript/browser/TestSetup.js'
      copy_file 'spec/javascript/server/TestSetup.js'
      copy_file 'spec/javascript/shared/testSpec.js'
    end
  end
end
