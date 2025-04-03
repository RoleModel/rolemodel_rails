#frozen_string_literal: true

module Rolemodel
  class SourceMapGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    def inject_config_for_production
      inject_into_file 'config/environments/production.rb', "\nrequire_relative Rails.root.join('lib/middleware/rolemodel/source_map.rb')\n", after: "require \"active_support/core_ext/integer/time\"\n"
      inject_into_file 'config/environments/production.rb', "\n  config.middleware.insert_after Warden::Manager, Rolemodel::SourceMap\n\n", after: "Rails.application.configure do\n"
    end

    def copy_middleware_files
      copy_file 'lib/middleware/rolemodel/source_map.rb'
    end

    def copy_assetes_rake_task
      copy_file 'lib/tasks/assets.rake'
    end
  end
end
