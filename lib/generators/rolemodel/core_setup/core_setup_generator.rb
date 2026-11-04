require_relative '../optics/icons/icon_library_options'

module Rolemodel
  class CoreSetupGenerator < ::Rolemodel::GeneratorBase
    include Optics::IconLibraryOptions

    class_option :skip_deployable, type: :boolean, default: false, desc: 'skip generators for app deployment (Heroku, Sentry, Lograge)'

    def install_agent_skills
      say 'Installing agent skills for the rolemodel_rails utilities', :green

      install_skill 'polymorphic-parent-resources'
      install_skill 'rake-tasks'
    end

    def run_the_core_generators
      generate 'rolemodel:slim'
      generate 'rolemodel:webpack'
      generate 'rolemodel:optics:all', *icon_library_flags
      generate 'rolemodel:simple_form'
      generate 'rolemodel:tom_select'
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
