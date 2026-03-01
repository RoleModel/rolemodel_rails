# frozen_string_literal: true

module Rolemodel
  class Engine < ::Rails::Engine
    generators do
      require 'generators/rolemodel/base_generator'
    end
  end
end
