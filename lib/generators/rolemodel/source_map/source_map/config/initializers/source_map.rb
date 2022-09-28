# frozen_string_literal: true

Rails.application.configure do
  #RoleModel::SourceMap(allowed_users_emails[, **options])
  #allowed_users_emails should be a String or a Array of Strings
  #Options for RoleModel::SourceMap
  # :root - The root directory from which files will be served (default: "maps")
  # :headers - A Hash of headers to be added to every response
  # (default: {'Set-Cookie' => 'Same-Site=None', 'Cache-Control' => 'max-age=0;no-cache'})
  config.middleware.use  RoleModel::SourceMap
end
