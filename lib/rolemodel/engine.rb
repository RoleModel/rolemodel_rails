# frozen_string_literal: true

module Rolemodel
  class Engine < ::Rails::Engine
    require_relative 'generator_base'
    require_relative 'resource_for/controller_extension'

    generators do
      require 'generators/rolemodel/all_generator'
    end

    initializer 'rolemodel.action_controller' do
      ActiveSupport.on_load(:action_controller_base) do
        include Rolemodel::ResourceFor::ControllerExtension
      end
    end
  end
end
