require 'rails'

module LightningCad
  module Generators
    class AllGenerator < ::Rails::Generators::Base
      generate 'lightning_cad:install'
      generate 'lightning_cad:test'
    end
  end
end
