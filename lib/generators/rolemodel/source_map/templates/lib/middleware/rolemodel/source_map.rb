# frozen_string_literal: true

module Middleware
  module Rolemodel
    class SourceMap
      def initialize(app, **options)
        root = options.delete(:root) || 'maps'
        default_headers = { 'Set-Cookie' => 'Same-Site=None', 'Cache-Control' => 'max-age=0;no-cache' }
        custom_headers = default_headers.merge(options.delete(:headers) || {})
        @app = app
        @allowed_users_emails = ENV.fetch('SOURCE_MAPS_ALLOWED_USERS_EMAILS', '').split(',')
        @file_server = Rack::Files.new(root, custom_headers)
      end

      def call(env)
        if allowed_sourcemap?(env)
          @file_server.call(env.tap { |env| env['PATH_INFO'].sub!(%r{^/[\w-]+[^/]}, '') })
        else
          @app.call(env)
        end
      end

      private

      def allowed_sourcemap?(env)
        return false unless env['PATH_INFO'].end_with?('.map')

        permit_user?(env)
      end

      def permit_user?(env)
        # Alternatively, allow sourcemaps for all super admins
        # current_user(env)&.super_admin?
        current_user_email = current_user(env)&.email
        return false if current_user_email.blank?

        @allowed_users_emails.include?(current_user_email)
      end

      def current_user(env)
        env['warden']&.user
      end
    end
  end
end
