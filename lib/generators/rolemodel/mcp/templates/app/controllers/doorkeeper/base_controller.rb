# frozen_string_literal: true

module Doorkeeper
  class BaseController < ::ApplicationController
    skip_forgery_protection
  end
end
