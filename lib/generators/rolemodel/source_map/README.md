# Rack middleware Generator

## What you get

* Rack middleware for serving source maps
* Enhanced assets rake tasks to relocate and manage source map files

Adds Rack middleware for serving js source maps only to allowed users in a production environment.

## Usage

* Ensure that app uses Warden::Manager middleware
* Set `SOURCE_MAPS_ALLOWED_USERS_EMAILS` to a comma-separated list of emails. The middleware reads it from `Rails.configuration.x.source_maps.allowed_user_emails`. To allow all super admins instead, change `permit_user?` in the middleware.
