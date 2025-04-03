# Rack middleware Generator

## What you get

* Rack middleware for serving source maps
* Enhanced assets rake tasks to relocate and manage source map files

Adds Rack middleware for serving js source maps only to allowed users in a production environment.

## Usage

* Ensure that app uses Warden::Manager middleware
* Set ENV['SOURCE_MAPS_ALLOWED_USERS_EMAILS'] to a space separated list of emails or update the middleware to allow all super admins
