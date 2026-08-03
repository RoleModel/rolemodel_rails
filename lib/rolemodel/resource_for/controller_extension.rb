module Rolemodel
  module ResourceFor
    module ControllerExtension
      extend ActiveSupport::Concern

      private

      def resource_for(type_symbol)
        params[type_symbol].safe_constantize.find(params[params[type_symbol].foreign_key])
      end
    end
  end
end
