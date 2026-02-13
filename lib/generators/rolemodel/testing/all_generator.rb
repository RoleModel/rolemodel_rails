module Rolemodel
  module Testing
    class AllGenerator < BaseGenerator
      source_root File.expand_path('templates', __dir__)

      def run_all_the_generators
        generate 'rolemodel:testing:factory_bot'
        if yes?('Would you like to add jasmine-playwright-runner for browser testing?')
          generate 'rolemodel:testing:jasmine_playwright'
        end
        generate 'rolemodel:testing:parallel_tests'
        generate 'rolemodel:testing:rspec'
        generate 'rolemodel:testing:test_prof'
      end
    end
  end
end
