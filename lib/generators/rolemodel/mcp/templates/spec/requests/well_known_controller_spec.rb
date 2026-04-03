# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'WellKnownController', type: :request do
  describe 'GET /.well-known/oauth-protected-resource' do
    it 'returns the MCP resource and authorization server' do
      get '/.well-known/oauth-protected-resource'

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body['resource']).to end_with('/mcp')
      expect(body['authorization_servers']).to be_an(Array)
    end
  end

  describe 'GET /.well-known/oauth-authorization-server' do
    it 'returns authorization server metadata with registration_endpoint' do
      get '/.well-known/oauth-authorization-server'

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body['registration_endpoint']).to end_with('/oauth/register')
      expect(body['authorization_endpoint']).to end_with('/oauth/authorize')
      expect(body['token_endpoint']).to end_with('/oauth/token')
      expect(body['code_challenge_methods_supported']).to include('S256')
      expect(body['scopes_supported']).to include('mcp')
    end
  end
end
