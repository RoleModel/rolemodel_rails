module Rolemodel
  module Testing
    class TestProfGenerator < Rails::Generators::Base
      def install_test_prof
        gem_group :test do
          gem 'test-prof'
        end
      end
    end
  end
end
