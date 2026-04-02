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

    it 'reads a database resource' do
      request = {
        jsonrpc: '2.0',
        id: 3,
        method: 'resources/read',
        params: { uri: 'database://schema/people' },
      }

      post '/mcp', params: request.to_json, headers: authorized_headers

      expect(response).to have_http_status(:ok)
      contents = response.parsed_body.dig('result', 'contents')
      expect(contents).to be_present
      expect(contents.first['uri']).to eq('database://schema/people')
      expect(contents.first['mimeType']).to eq('text/markdown')
      expect(contents.first['text']).to include('Schema')
    end

    it 'returns an error for an invalid resource URI' do
      request = {
        jsonrpc: '2.0',
        id: 6,
        method: 'resources/read',
        params: { uri: 'something://invalid' },
      }

      post '/mcp', params: request.to_json, headers: authorized_headers

      expect(response).to have_http_status(:ok)
      error = response.parsed_body['error']
      expect(error).to be_present
      expect(error['code']).to eq(JsonRpcHandler::ErrorCode::INVALID_PARAMS) # -32602
      expect(error['message']).to eq('Invalid params')
      expect(error['data']).to include('Unable to serve resource for URI')
    end

    it 'lists prompts' do
      request = {
        jsonrpc: '2.0',
        id: 4,
        method: 'prompts/list',
        params: {},
      }

      post '/mcp', params: request.to_json, headers: authorized_headers

      expect(response).to have_http_status(:ok)
      prompts = response.parsed_body.dig('result', 'prompts')
      expect(prompts).to be_present

      blazer_prompt = prompts.find { |prompt| prompt['name'] == 'blazer_sql_assistant' }
      expect(blazer_prompt).to be_present
      expect(blazer_prompt['title']).to eq('Blazer SQL Assistant')
    end

    it 'returns blazer prompt content' do
      request = {
        jsonrpc: '2.0',
        id: 5,
        method: 'prompts/get',
        params: { name: 'blazer_sql_assistant', arguments: {} },
      }

      post '/mcp', params: request.to_json, headers: authorized_headers

      expect(response).to have_http_status(:ok)
      result = response.parsed_body['result']
      expect(result).to be_present
      expect(result['description']).to include('Blazer report queries')

      message_text = result.dig('messages', 0, 'content', 'text')
      expect(message_text).to include('You specialize in making PostgreSQL queries')
    end
  end
end
