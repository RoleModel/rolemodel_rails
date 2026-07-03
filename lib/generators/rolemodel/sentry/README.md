# Sentry Generator

## What you get

Error monitoring and performance tracing via [Sentry](https://sentry.io) for both the Ruby and JavaScript sides of the app.

### Ruby

* The `sentry-rails` gem
* `config/initializers/sentry.rb` with sensible defaults: traces sampling, profiling, PII filtering via Rails' parameter filter, noisy-exception exclusion, and health-check transaction filtering
* Sentry user context wired into `app/controllers/application_controller.rb` via a `set_sentry_user` before_action (Devise-friendly, gated on `user_signed_in?`)

### JavaScript

* `@sentry/browser` and `@sentry/webpack-plugin` dependencies
* `app/javascript/initializers/sentry.js`, which initializes Sentry in production and staging only (avoids ad-blocker noise in development) and attaches the current user from a `current-user-id` meta tag
* The `sentryWebpackPlugin` wired into `webpack.config.js` to upload source maps in production

Depends on the `rolemodel:webpack` generator having already created `webpack.config.js` and `app/javascript/application.js`.

## After running

* Update the `project` and `applicationKey` in `webpack.config.js`, and the matching `filterKeys` in `app/javascript/initializers/sentry.js`, to match your Sentry project.
* Set the `SENTRY_DSN`, `SENTRY_ENVIRONMENT`, and `SENTRY_AUTH_TOKEN` environment variables.
* Render a `current-user-id` meta tag in your layout so the browser SDK can attach user context.
