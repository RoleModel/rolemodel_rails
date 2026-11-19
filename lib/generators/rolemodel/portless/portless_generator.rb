# frozen_string_literal: true

module Rolemodel
  class PortlessGenerator < GeneratorBase
    source_root File.expand_path('templates', __dir__)

    def copy_bin_portless
      copy_file 'bin/portless'
      chmod 'bin/portless', 0o755
    end

    def create_procfile_pdev
      app_name = Rails.application.class.module_parent_name.underscore.dasherize
      procfile = File.read(File.join(destination_root, 'Procfile.dev'))
      create_file 'Procfile.pdev', procfile.sub(%r{bin/rails server}, "portless #{app_name} bin/rails server")
    end
  end
end
