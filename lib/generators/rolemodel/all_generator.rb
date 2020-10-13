module Rolemodel
  class AllGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    def set_ruby_version
      remove_file '.ruby-version'
      create_file '.ruby-version', '2.7.2'
    end

    def run_all_the_generators
      generate 'rolemodel:css:all'
      generate 'rolemodel:github'
      generate 'rolemodel:heroku'
      generate 'rolemodel:readme'
      generate 'rolemodel:webpacker'
      generate 'rolemodel:testing:all'
      generate 'rolemodel:saas:all'
    end
  end
end
