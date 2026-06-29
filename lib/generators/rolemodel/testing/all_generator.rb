module Rolemodel
  module Testing
    class AllGenerator < GeneratorBase
      source_root File.expand_path('templates', __dir__)

      class_option :js_runner, type: :boolean, default: false, desc: 'Include jasmine-playwright-runner for browser testing'

      def run_all_the_generators
        generate 'rolemodel:testing:factory_bot', [inline: false]
        generate('rolemodel:testing:jasmine_playwright', [inline: false]) if options.js_runner?
        generate 'rolemodel:testing:parallel_tests', [inline: false]
        generate 'rolemodel:testing:rspec', [inline: false]
        generate 'rolemodel:testing:test_prof', [inline: false]
      end
    end
  end
end
