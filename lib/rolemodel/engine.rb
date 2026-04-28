# frozen_string_literal: true

module Rolemodel
  class Engine < ::Rails::Engine
    require_relative 'generator_base'

    paths.add 'rolemodel/optics', eager_load: true

    generators do
      require 'generators/rolemodel/all_generator'
    end
  end
end
