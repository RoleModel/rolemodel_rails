#frozen_string_literal: true

module Rolemodel
  class SourceMapGenerator < Rails::Generators::Base
    source_root File.expand_path(__dir__)

    def copy_source_map_files
      copy_entry 'source_map', 'app'
    end
  end
end
