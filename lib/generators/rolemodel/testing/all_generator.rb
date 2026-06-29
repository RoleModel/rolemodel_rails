module Rolemodel
  module Testing
    class AllGenerator < GeneratorBase
      source_root File.expand_path('templates', __dir__)

      class_option :js_runner, type: :boolean, default: false, desc: 'Include jasmine-playwright-runner for browser testing'

      def run_all_the_generators
        generate 'rolemodel:testing:factory_bot'
        generate 'rolemodel:testing:jasmine_playwright' if options.js_runner?
        generate 'rolemodel:testing:parallel_tests'
        generate 'rolemodel:testing:rspec'
        generate 'rolemodel:testing:test_prof'
      end
    end
  end
end
