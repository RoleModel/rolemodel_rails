module Rolemodel
  class AllGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    def run_all_the_generators
      generate 'rolemodel:github'
      generate 'rolemodel:semaphore'
      generate 'rolemodel:heroku'
      generate 'rolemodel:readme'
      generate 'rolemodel:webpack'
      generate 'rolemodel:react'
      generate 'rolemodel:css:all'
      generate 'rolemodel:testing:all'
      generate 'rolemodel:simple_form'
      generate 'rolemodel:soft_destroyable'
      generate 'rolemodel:saas:all'
      generate 'rolemodel:editors'
      generate 'rolemodel:linters:all'
      generate 'rolemodel:mailers'
      generate 'rolemodel:source_map'
    end
  end
end
