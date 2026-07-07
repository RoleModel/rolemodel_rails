module Rolemodel
  class CoreSetupGenerator < ::Rolemodel::GeneratorBase
    def run_the_core_generators
      generate 'rolemodel:github'
      generate 'rolemodel:heroku'
      generate 'rolemodel:readme'
      generate 'rolemodel:webpack --sentry'
      generate 'rolemodel:sentry'
      generate 'rolemodel:slim'
      generate 'rolemodel:optics:all'
      generate 'rolemodel:testing:all'
      generate 'rolemodel:simple_form'
      generate 'rolemodel:linters:all'
      generate 'rolemodel:ui_components:flash'
      generate 'rolemodel:ui_components:modals'
      generate 'rolemodel:lograge'
    end
  end
end
