# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MCPPolicy do
  let(:user) { create :client }
  let(:record) { :mcp }
  let(:context) { { user: user } }

  describe_rule :handle? do
    succeed 'when logged in'

    failed 'when anonymous' do
      let(:user) { nil }
    end
  end
end
