# frozen_string_literal: true

module Doorkeeper
  class BaseController < ::ApplicationController
    skip_before_action :authenticate_oauth, raise: false
    skip_forgery_protection
  end
end
