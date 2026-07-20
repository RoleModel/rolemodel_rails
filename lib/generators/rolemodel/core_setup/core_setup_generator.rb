module Rolemodel
  class CoreSetupGenerator < ::Rolemodel::GeneratorBase
    def run_the_core_generators
      generate 'rolemodel:slim'
      generate 'rolemodel:webpack'
      generate 'rolemodel:optics:all'
      generate 'rolemodel:simple_form'
      generate 'rolemodel:testing:all'
      generate 'rolemodel:turbo:all'
      generate 'rolemodel:ui_components:flash'
      generate 'rolemodel:github'
      generate 'rolemodel:heroku'
      generate 'rolemodel:readme'
      generate 'rolemodel:sentry'
      generate 'rolemodel:linters:all'
      generate 'rolemodel:lograge'
    end
  end
end
