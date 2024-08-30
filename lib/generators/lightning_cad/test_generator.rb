require 'rails'

module LightningCad
  class TestGenerator < Rails::Generators::Base
    source_root File.expand_path('./templates', __dir__)

    def add_jasmine_tests
      say 'Adding jasmine'
      run "yarn add --dev jasmine@^5.1.0"

      run 'npm pkg set scripts.test_shared="NODE_OPTIONS=\'--import=./app/javascript/helpers/register_hooks.js\' jasmine --config=jasmine.json"'

      copy_file 'jasmine.json', 'jasmine.json'
      copy_file 'spec/javascript/helpers/initializers.js', 'spec/javascript/helpers/initializers.js'
      copy_file 'spec/javascript/shared/.eslintrc.js', 'spec/javascript/shared/.eslintrc.js'
      copy_file 'spec/javascript/shared/TestSetup.js', 'spec/javascript/shared/TestSetup.js'
      copy_file 'spec/javascript/shared/testSpec.js', 'spec/javascript/shared/testSpec.js'
    end

    def add_test_initializers
      say 'Adding test initializers'

      copy_file 'spec/javascript/helpers/initializers.js', 'spec/javascript/helpers/initializers.js'
    end
  end
end
