module Rolemodel
  class CoreSetupGenerator < ::Rolemodel::GeneratorBase
    class_option :js_runner, type: :boolean, default: false, desc: 'Include jasmine-playwright-runner for browser testing'

    def run_the_core_generators
      generate 'rolemodel:github'
      generate 'rolemodel:heroku'
      generate 'rolemodel:readme'
      generate 'rolemodel:webpack'
      generate 'rolemodel:sentry'
      generate 'rolemodel:slim'
      generate 'rolemodel:optics:all'
      generate 'rolemodel:testing:all', options.js_runner? ? '--js-runner' : '--no-js-runner'
      generate 'rolemodel:simple_form'
      generate 'rolemodel:linters:all'
      generate 'rolemodel:ui_components:all'
      generate 'rolemodel:editors'
      generate 'rolemodel:lograge'
    end
  end
end
