# frozen_string_literal: true

class MCPPolicy < ApplicationPolicy
  def handle?
    user.present?
  end
end
