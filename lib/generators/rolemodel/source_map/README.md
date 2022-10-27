# Rack middleware Generator

## What you get

* Rack middleware for serving source maps

Adds Rack middleware for serving js source maps only to allowed users in a production environment.

## Usage
    
* Ensure that app uses Warden::Manager middleware
* Set ENV['SOURCE_MAPS_ALLOWED_USERS_EMAILS'] to a space separated list of emails
* Next configs must be applied to a bundling tool (e.g. Webpack):
    * [bundle].js needs to be placed in [RAILS_ROOT]/public/packs/js directory
    * Generate  source maps and append sourceMappingURL=[bundle].js bundled file
    * Relocate source maps out of [RAILS_ROOT]/public/packs/js/ directory to the [RAILS_ROOT]/maps/js directory
