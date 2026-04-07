# frozen_string_literal: true

class OauthRegistrationsController < ApplicationController
  # skip_before_action :authenticate_user!
  # skip_verify_authorized
  skip_forgery_protection

  def create
    app = Doorkeeper::Application.new(doorkeeper_params)
    return client_metadata_error('redirect_uris is required') if app.redirect_uri.blank?

    if app.save
      render json: base_response(app), status: :created
    else
      client_metadata_error(app.errors.full_messages.join(', '))
    end
  end

  private

  def base_response(app)
    {
      client_id: app.uid,
      client_name: app.name,
      redirect_uris: app.redirect_uri.split("\n"),
      grant_types: %w[authorization_code refresh_token],
      response_types: ['code'],
      token_endpoint_auth_method: app.confidential? ? 'client_secret_basic' : 'none',
      client_id_issued_at: app.created_at.to_i,
      scope: 'mcp',
      client_secret: app.confidential? ? app.secret : nil,
    }.compact
  end

  def client_metadata_error(description)
    render json: { error: 'invalid_client_metadata', error_description: description }, status: :bad_request
  end

  def doorkeeper_params
    {
      name: params[:client_name].presence || 'MCP Client',
      redirect_uri: params[:redirect_uris].is_a?(Array) ? params[:redirect_uris].join("\n") : params[:redirect_uris],
      scopes: 'mcp',
      confidential: params[:token_endpoint_auth_method] != 'none',
    }
  end
end
