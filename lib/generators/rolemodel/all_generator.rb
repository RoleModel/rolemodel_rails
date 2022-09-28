module Rolemodel
  class AllGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    def run_all_the_generators
      generate 'rolemodel:css:all'
      generate 'rolemodel:github'
      generate 'rolemodel:heroku'
      generate 'rolemodel:linters:all'
      generate 'rolemodel:mailers'
      generate 'rolemodel:readme'
      generate 'rolemodel:saas:all'
      generate 'rolemodel:semaphore'
      generate 'rolemodel:simple_form'
      generate 'rolemodel:soft_destroyable'
      generate 'rolemodel:source_map'
      generate 'rolemodel:testing:all'
      generate 'rolemodel:webpacker'
    end
  end
end
