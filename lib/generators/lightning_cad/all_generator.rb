require 'rails'

module LightningCad
  class AllGenerator < Rails::Generators::Base
    source_root File.expand_path('./templates', __dir__)

    def run_all_the_generators
      generate 'lightning_cad:install'
      generate 'lightning_cad:test'
    end
  end
end
