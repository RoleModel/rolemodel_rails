require_relative '../../bundler_helpers'

module Rolemodel
  class KaminariGenerator < Rails::Generators::Base
    include Rolemodel::BundlerHelpers
    source_root File.expand_path('templates', __dir__)

    def install_kaminari
      run 'bundle add kaminari'

      generate 'kaminari:config'
    end

    def copy_templates
      directory 'app/views/kaminari'
    end
  end
end
