module Rolemodel
  module Testing
    class AllGenerator < GeneratorBase
      source_root File.expand_path('templates', __dir__)

      class_option :js_runner, type: :boolean, default: false, desc: 'Include jasmine-playwright-runner for browser testing'

      def run_all_the_generators
        generate 'rolemodel:testing:factory_bot', abort_on_failure: true
        generate('rolemodel:testing:jasmine_playwright', abort_on_failure: true) if options.js_runner?
        generate 'rolemodel:testing:parallel_tests', abort_on_failure: true
        generate 'rolemodel:testing:rspec', abort_on_failure: true
        generate 'rolemodel:testing:test_prof', abort_on_failure: true
      end
    end
  end
end
