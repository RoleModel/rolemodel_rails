require_relative '../../../bundler_helpers'

module Rolemodel
  module Testing
    class TestProfGenerator < Rails::Generators::Base
      include Rolemodel::BundlerHelpers
      def install_test_prof
        gem_group :test do
          gem 'test-prof'
        end
        run_bundle
      end
    end
  end
end
