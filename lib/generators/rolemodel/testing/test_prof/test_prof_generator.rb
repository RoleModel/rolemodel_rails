# frozen_string_literal: true

module Rolemodel
  module Testing
    class TestProfGenerator < Rails::Generators::Base
      include BundlerHelpers
      def install_test_prof
        gem_group :test do
          gem 'test-prof'
        end
        run_bundle
      end
    end
  end
end
