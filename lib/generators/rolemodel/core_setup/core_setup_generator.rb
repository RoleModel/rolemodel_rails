module Rolemodel
  class CoreSetupGenerator < ::Rolemodel::GeneratorBase
    # Composite generator: it orchestrates other generators and installs nothing
    # itself, so it is not recorded in the registry.
    skip_registry_entry!

    def run_the_core_generators
      generate 'rolemodel:github'
      generate 'rolemodel:heroku'
      generate 'rolemodel:readme'
      generate 'rolemodel:webpack'
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
