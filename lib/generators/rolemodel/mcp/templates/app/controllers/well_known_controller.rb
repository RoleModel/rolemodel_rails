# frozen_string_literal: true

class WellKnownController < ApplicationController
  # skip_before_action :authenticate_user!
  before_action :set_base_url

  def oauth_protected_resource
    render json: {
      resource: "#{@base_url}/mcp",
      authorization_servers: [@base_url],
    }
  end

  def oauth_authorization_server
    render json: authorization_server_metadata
  end

  private

  def authorization_server_metadata # rubocop:disable Metrics/MethodLength
    {
      issuer: @base_url,
      authorization_endpoint: "#{@base_url}/oauth/authorize",
      token_endpoint: "#{@base_url}/oauth/token",
      registration_endpoint: "#{@base_url}/oauth/register",
      revocation_endpoint: "#{@base_url}/oauth/revoke",
      introspection_endpoint: "#{@base_url}/oauth/introspect",
      scopes_supported: ['mcp'],
      response_types_supported: ['code'],
      grant_types_supported: %w[authorization_code client_credentials refresh_token],
      token_endpoint_auth_methods_supported: %w[none client_secret_basic client_secret_post],
      code_challenge_methods_supported: ['S256'],
    }
  end

  def set_base_url
    @base_url = request.base_url
  end
end
