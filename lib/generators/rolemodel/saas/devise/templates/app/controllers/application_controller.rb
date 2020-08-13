class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  private

  def current_organization
    current_user.try(:organization)
  end
end
