# frozen_string_literal: true

module Rolemodel
  NODE_VERSION = '24.12.0'
  RUBY_VERSION = '4.0.1'
end

require 'rolemodel/version'

begin
  require 'rails/engine'
rescue LoadError
end

require 'rolemodel/engine' if defined?(Rails::Engine)
