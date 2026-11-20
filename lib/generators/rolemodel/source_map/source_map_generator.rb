# frozen_string_literal: true

module Rolemodel
  class SourceMapGenerator < GeneratorBase
    source_root File.expand_path('templates', __dir__)

    def inject_config_for_production
      prepend_to_file 'config/environments/production.rb',
                      "require_relative Rails.root.join('lib/middleware/rolemodel/source_map.rb')\n"
      append_to_environment 'production', <<~'RUBY'
        config.middleware.insert_after Warden::Manager, Middleware::Rolemodel::SourceMap
      RUBY
    end

    def copy_middleware_files
      add_setting "config.x.source_maps.allowed_user_emails = EnvValue.array('SOURCE_MAPS_ALLOWED_USERS_EMAILS')"
      copy_file 'lib/middleware/rolemodel/source_map.rb'
    end

    def copy_assets_rake_task
      copy_file 'lib/tasks/assets.rake'
    end
  end
end
