module Rolemodel
  class CoreSetupGenerator < ::Rolemodel::GeneratorBase
    class_option :skip_deployable, type: :boolean, default: false, desc: 'skip generators for app deployment (Heroku, Sentry, Lograge)'

    def run_the_core_generators
      generate 'rolemodel:slim'
      generate 'rolemodel:webpack'
      generate 'rolemodel:optics:all'
      generate 'rolemodel:simple_form'
      generate 'rolemodel:testing:all'
      generate 'rolemodel:turbo:all'
      generate 'rolemodel:ui_components:flash'
      generate 'rolemodel:github'
      generate 'rolemodel:readme'
      generate 'rolemodel:linters:all'
      return if options.skip_deployable?

      generate 'rolemodel:heroku'
      generate 'rolemodel:sentry'
      generate 'rolemodel:lograge'
    end
  end
end
