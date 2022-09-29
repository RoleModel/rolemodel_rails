# frozen_string_literal: true

module Rolemodel
  class SourceMapGenerator < Rails::Generators::Base
    def initialize(app, allowed_users_emails = [], **options)
      root = options.delete(:root) || 'maps'
      default_headers = {'Set-Cookie' => 'Same-Site=None', 'Cache-Control' => 'max-age=0;no-cache'}
      custom_headers = default_headers.merge(options.delete(:headers) || {})
      @app = app
      @allowed_users_emails = allowed_users_emails
      @file_server = Rack::Files.new(root, custom_headers)
    end

    def call(env)
      serve? ? @file_server.call(env.tap { |env| env['PATH_INFO'].sub!(/^\/[\w-]+[^\/]/, '') }) : @app.call(env)
    end

    private

    def serve?(env)
      ENV['RAILS_ENV'] == 'production' && env['PATH_INFO'].match?(/\.map\z/) && permit_user?(env)
    end

    def permit_user?(env)
      (current_user_email = current_user(env)&.email) &&
        (current_user_email.include?('@rolemodelsoftware.com') || @allowed_users_emails.include?(current_user_email))
    end

    def current_user(env)
      env['warden'].user
    end
  end
end
