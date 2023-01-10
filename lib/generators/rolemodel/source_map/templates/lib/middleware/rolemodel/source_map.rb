# frozen_string_literal: true

module Rolemodel
  class SourceMap
    def initialize(app, **options)
      root = options.delete(:root) || 'maps'
      default_headers = {'Set-Cookie' => 'Same-Site=None', 'Cache-Control' => 'max-age=0;no-cache'}
      custom_headers = default_headers.merge(options.delete(:headers) || {})
      @app = app
      @allowed_users_emails = ENV['SOURCE_MAPS_ALLOWED_USERS_EMAILS'] || nil
      @file_server = Rack::Files.new(root, custom_headers)
    end

    def call(env)
      serve?(env) ? @file_server.call(env.tap { |env| env['PATH_INFO'].sub!(/^\/[\w-]+[^\/]/, '') }) : @app.call(env)
    end

    private

    def serve?(env)
      ENV['RAILS_ENV'] == 'production' && env['PATH_INFO'].match?(/\.map\z/) && permit_user?(env)
    end

    def permit_user?(env)
      (current_user_email = current_user(env)&.email)&.empty? && @allowed_users_emails&.include?(current_user_email)
    end

    def current_user(env)
      env['warden']&.user
    end
  end
end
