# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'MCPController', type: :request do
  let(:user) { create(:user, name: 'Jane Smith', active: true, employee: true) }
  let(:application) do
    Doorkeeper::Application.create!(
      name: 'MCP Test Client',
      redirect_uri: 'https://example.com/callback',
      scopes: 'mcp',
    )
  end

  describe 'POST /mcp' do
    let(:token) do
      Doorkeeper::AccessToken.create!(
        application: application,
        resource_owner_id: user.id,
        scopes: 'mcp',
        expires_in: 2.hours.to_i,
      )
    end

    let(:initialize_request) do
      {
        jsonrpc: '2.0',
        id: 1,
        method: 'initialize',
        params: {
          protocolVersion: '2025-11-25',
          capabilities: {},
          clientInfo: {
            name: 'rspec',
            version: '1.0',
          },
        },
      }
    end

    let(:headers) do
      {
        'CONTENT_TYPE' => 'application/json',
        'ACCEPT' => 'application/json, text/event-stream',
      }
    end

    let(:authorized_headers) do
      headers.merge('Authorization' => "Bearer #{token.token}")
    end

    it 'returns unauthorized when no bearer token is provided' do
      post '/mcp', params: initialize_request.to_json, headers: headers

      expect(response).to have_http_status(:unauthorized)
      expect(response.headers['WWW-Authenticate']).to include('resource_metadata=')
    end

    it 'returns forbidden when token does not include mcp scope' do
      token = Doorkeeper::AccessToken.create!(
        application: application,
        resource_owner_id: user.id,
        scopes: 'other',
        expires_in: 2.hours.to_i,
      )

      post '/mcp',
        params: initialize_request.to_json,
        headers: headers.merge('Authorization' => "Bearer #{token.token}")

      expect(response).to have_http_status(:forbidden)
    end

    it 'returns initialize response for a valid bearer token' do
      post '/mcp',
        params: initialize_request.to_json,
        headers: authorized_headers

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['result']).to be_present
      expect(response.parsed_body['result']['capabilities']).to include('tools')
    end
  end
end
