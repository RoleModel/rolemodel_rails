require 'rails'

module LightningCad
  class AllGenerator < Rails::Generators::Base
    generate 'lightning_cad:install'
    generate 'lightning_cad:test'
  end
end
