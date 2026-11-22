# Dotenv Generator

[USAGE](./USAGE)

Sets up local settings in a `.env.local` file, and adds `EnvValue` to read settings from ENV.

Run it with:

```
bin/rails generate rolemodel:dotenv
```

## What you get

  - The `dotenv` gem in the `development` and `test` groups.
  - `/.env*` in `.gitignore`, so Git never commits your local values. New Rails apps already ignore it.
  - `lib/env_value.rb`, required from `config/application.rb`.
  - `spec/lib/env_value_spec.rb`, when the app has a `spec` folder.

## Put a local value in `.env.local`

Create `.env.local` in the project root. Add one `KEY=value` line for each setting:

```
SENDGRID_API_KEY=xxxxxxxxx
```

Restart the server after you change the file.

To copy values from a Heroku app, run `heroku config -s -a <app>`. It prints `KEY=value` lines. Paste the lines you need into `.env.local`.

The dotenv gem loads `.env.local` in development. Tests don't read `.env.local`, so a test run never depends on your machine. Put a value that tests need in `.env.test`, or give it a `local:` or `default:` value (see [Defaults for each environment](#defaults-for-each-environment)). Production reads its values from the host, for example Heroku config vars.

## Read a setting with `EnvValue`

`EnvValue` reads a value from ENV. A blank value counts as unset. When the value is unset, `EnvValue` uses a default.

Read each setting once in `config/application.rb`, and keep it as a `config.x` value:

```ruby
config.x.sendgrid.api_key = EnvValue.string('SENDGRID_API_KEY')
config.x.report_emails = EnvValue.array('REPORT_EMAILS', default: %w[team@example.com])
config.x.serve_static_files = EnvValue.boolean('RAILS_SERVE_STATIC_FILES')
config.x.default_url = EnvValue.url('DEFAULT_URL', default: 'http://localhost:3000')
```

Then read it in app code:

```ruby
Rails.configuration.x.sendgrid.api_key
```

| Method | Returns | When unset, with no default | When the value is not valid |
|---|---|---|---|
| `string` | the text | `nil` | — |
| `string!` | the text | raises | raises when blank |
| `array` | the comma-separated items, trimmed | `[]` | — |
| `boolean` | `true` for `true`, `t`, `1`, `yes`, `y`, `on`, `enabled`. `false` for `false`, `f`, `0`, `no`, `n`, `off`, `disabled`. Case does not matter. | `false` | raises on any other text, naming the key |
| `url` | the URL | `nil` | raises when it has no scheme or host |

Read settings in `config/application.rb`, so a raise stops the app when it starts. Then you see a bad value at once.

### Defaults for each environment

A default can be different in each environment. `EnvValue` uses the first of these that applies:

  1. A key named for the current environment, such as `production:` or `staging:`. A key set to `nil` counts, and gives `nil`.
  2. `local:`, in development and test only.
  3. A block.
  4. `default:`.

```ruby
# Every environment except production falls back to dev-key. Staging gets dev-key too.
# Production gets nil unless ENCRYPTION_KEY is set.
EnvValue.string('ENCRYPTION_KEY', default: 'dev-key', production: nil)

# Only development and test fall back to dev-client-id. Staging and production get nil.
EnvValue.string('API_CLIENT_ID', local: 'dev-client-id')

# The block runs only when the key is unset.
EnvValue.url('DEFAULT_URL') { "https://#{EnvValue.string('HEROKU_APP_NAME')}.herokuapp.com" }
```

## Move from `env.rb`

Some RoleModel apps keep local settings in `env.rb` and `.env_overrides.rb`. Those are Ruby files, so only Ruby can read them. A `.env` file holds plain `KEY=value` lines that Ruby, Node, Docker Compose, foreman and 1Password can all read.

If the app has `env.rb` or `.env_overrides.rb`:

  1. Run the generator.
  2. Move each `ENV['KEY'] ||= 'value'` line from `env.rb` and `.env_overrides.rb` to `.env.local` as `KEY=value`.
  3. If `env.rb` set a value that production uses, add it as a default in `config/application.rb` with `EnvValue`.
  4. Remove the line that requires `env.rb` from `config/application.rb`.
  5. Delete `env.rb` and `.env_overrides.rb`.

## Generators that add settings

These generators add their settings to `config/application.rb` with `EnvValue`. If the app has no `lib/env_value.rb`, they run this generator first.

| Generator | ENV key | Setting |
|---|---|---|
| `rolemodel:heroku` | `LOG_LEVEL` | `config.x.log_level` (default `INFO`) |
| `rolemodel:sentry` | `SENTRY_DSN` | `config.x.sentry.dsn` |
| `rolemodel:mailers` | `WHITELISTED_EMAILS` | `config.x.whitelisted_emails` |
| | `HEROKU_APP_NAME` | `config.x.heroku_app_name` |
| | `PRODUCTION_HOST` | `config.x.production_host` |
| | `SENDGRID_API_KEY` | `config.x.sendgrid.api_key` |
| `rolemodel:saas:devise` | `REVIEW_APP` | `config.x.review_app` |
| | `HEROKU_APP_NAME` | `config.x.heroku_app_name` |
| | `PRODUCTION_HOST` | `config.x.production_host` |
| `rolemodel:source_map` | `SOURCE_MAPS_ALLOWED_USERS_EMAILS` | `config.x.source_maps.allowed_user_emails` |
| `rolemodel:good_job` | `GOOD_JOB_QUEUES` | `config.x.good_job.queues` (default `pdf:1;-pdf`) |
