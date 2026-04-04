# frozen_string_literal: true

module Rolemodel
  class Engine < ::Rails::Engine
    require_relative 'generator_base'

    generators do
      require 'generators/rolemodel/all_generator'
    end
  end
end
