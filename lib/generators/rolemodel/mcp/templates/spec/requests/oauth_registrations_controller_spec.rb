# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'OauthRegistrationsController', type: :request do
  describe 'POST /oauth/register' do
    let(:params) do
      {
        client_name: 'GitHub Copilot',
        redirect_uris: ['http://localhost:12345/callback'],
        grant_types: ['authorization_code'],
        response_types: ['code'],
        token_endpoint_auth_method: 'none',
        scope: 'mcp',
      }
    end

    it 'creates an OAuth application and returns client_id' do
      expect { post '/oauth/register', params: params, as: :json }
        .to change(Doorkeeper::Application, :count).by(1)

      expect(response).to have_http_status(:created)
      body = response.parsed_body
      expect(body['client_id']).to be_present
      expect(body['client_name']).to eq('GitHub Copilot')
      expect(body['redirect_uris']).to eq(['http://localhost:12345/callback'])
      expect(body['token_endpoint_auth_method']).to eq('none')
      expect(body).not_to have_key('client_secret')

      app = Doorkeeper::Application.last
      expect(app.name).to eq('GitHub Copilot')
      expect(app.redirect_uri).to eq('http://localhost:12345/callback')
      expect(app.scopes).to contain_exactly('mcp')
      expect(app).not_to be_confidential
    end

    it 'returns bad_request when redirect_uris is missing' do
      post '/oauth/register', params: { client_name: 'Test' }, as: :json

      expect(response).to have_http_status(:bad_request)
      expect(response.parsed_body['error']).to eq('invalid_client_metadata')
    end

    it 'creates a confidential client when token_endpoint_auth_method is not none' do
      params[:token_endpoint_auth_method] = 'client_secret_basic'
      post '/oauth/register', params: params, as: :json

      expect(response).to have_http_status(:created)
      body = response.parsed_body
      expect(body['client_secret']).to be_present
      expect(body['token_endpoint_auth_method']).to eq('client_secret_basic')
    end

    it 'allows loopback redirect URIs for native clients' do
      params[:redirect_uris] = ['http://127.0.0.1:33418/']
      post '/oauth/register', params: params, as: :json

      expect(response).to have_http_status(:created)
      expect(response.parsed_body['redirect_uris']).to eq(['http://127.0.0.1:33418/'])
    end
  end
end
