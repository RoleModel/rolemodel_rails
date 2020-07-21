module Rolemodel
  class AllGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    def run_all_the_generators
      generate 'rolemodel:css:all'
      generate 'rolemodel:github'
      generate 'rolemodel:heroku'
      generate 'rolemodel:readme'
      generate 'rolemodel:webpacker'
      generate 'rolemodel:webpacker:dev'
      generate 'rolemodel:testing:all'
      generate 'rolemodel:saas:all'
    end
  end
end
