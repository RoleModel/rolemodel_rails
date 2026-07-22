module Rolemodel
  class CoreSetupGenerator < ::Rolemodel::GeneratorBase
    class_option :deployable, type: :boolean, default: true, desc: 'Include generators for app deployment (Heroku, Sentry, Lograge)'

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
      return unless options.deployable?

      generate 'rolemodel:heroku'
      generate 'rolemodel:sentry'
      generate 'rolemodel:lograge'
    end
  end
end
