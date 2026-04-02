# frozen_string_literal: true

ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.acronym "MCP"
end

module Rolemodel
  NODE_VERSION = '24.12.0'
  RUBY_VERSION = '4.0.1'
end

require 'rolemodel/version'
require 'rolemodel/engine'
