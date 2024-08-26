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
      generate 'rolemodel:slim'
      generate 'rolemodel:optics:all'
      generate 'rolemodel:testing:all'
      generate 'rolemodel:simple_form'
      generate 'rolemodel:soft_destroyable'
      generate 'rolemodel:saas:all'
      generate 'rolemodel:mailers'
      generate 'rolemodel:linters:all'
      generate 'rolemodel:modals'
      generate 'rolemodel:source_map'
      generate 'rolemodel:good_job'
      generate 'rolemodel:kaminari'
      generate 'rolemodel:editors'
      generate 'rolemodel:tailored_select'
    end
  end
end
