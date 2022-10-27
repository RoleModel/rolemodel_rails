#frozen_string_literal: true

module Rolemodel
  class SourceMapGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    def copy_initializer_file
      copy_file 'config/initializers/source_map.rb'
    end

    def copy_middleware_files
      copy_file 'app/middleware/rolemodel/source_map'
    end
  end
end
