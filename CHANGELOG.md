# Changelog

## [v2.4.1] Aug 19, 2026

- `rolemodel:all` no longer fails calling the Semaphore generator, which was removed in 2.2.0.

## [v2.4.0] Aug 4, 2026

- `resource_for`, a private method on every controller, serves a child resource with many possible
  parents (comments, attachments, reports) from one controller. A route concern sets the parent's
  type as a route default, and `resource_for` finds the parent from it and its id param. See the
  README's routing and security notes.

## [v2.3.2] Jul 28, 2026

- Generators run Yarn through `yarn_command` on `GeneratorBase`, which sets up Corepack and Yarn 4+
  first if the app doesn't have them yet. It replaces the per-generator `ensure_yarn` calls.

## [v2.3.1] Jul 22, 2026

- Release tooling only: removes a `vendor/bundle` that had been committed and fixes the version bump
  workflow. The gem's behavior doesn't change.

## [v2.3.0] Jul 22, 2026

- `rolemodel:turbo` generators replace `rolemodel:ui_components:modals`, so each part can be
  installed on its own: `turbo:ready`, `turbo:confirm`, `turbo:form`, `turbo:modals [--panels]`, and
  `turbo:all` for everything. `core_setup` uses them.
- `rolemodel:yarn:setup` sets up Corepack and Yarn 4+ as a command of its own.
- The Sentry generator's per-user error context is a controller concern, `SentryUser`.
- Generators no longer write to `application.scss`; the Shoelace component styles are plain CSS.
- Version bumps, tags, GitHub releases, and RubyGems publishing run from GitHub Actions.

## [v2.2.0] Jul 14, 2026

- `rolemodel:core_setup` runs only the generators a brand-new app needs. `rolemodel:all` still runs
  everything.
- Sentry replaces Honeybadger for Ruby and JavaScript error reporting, with source map upload from
  webpack and the current user in error context.
- Projects use Corepack-managed Yarn 4+ instead of Yarn 1.22.
- A Heroku deploy-app agent skill, with GitHub Actions workflows to deploy staging and production.
- The generated Gemfile pins the Ruby version, and the production database config reads
  `DATABASE_URL`, so a new app deploys to Heroku as is.
- The Tailored Select input is offered during Simple Form setup instead of always installed.
- The Semaphore generator is gone.

## [v2.1.0] Jul 6, 2026

- `Rolemodel::Utility::TaskTools` adds `dry_run?` and `sanitize_arguments` for rake tasks, and the
  README documents the module.

## [v2.0.1] Jul 3, 2026

Everything since 1.1.0 ships together here, including the 1.2.0 and 1.3.0 bumps that never reached
RubyGems.

- The MCP generator is gone; that work lives in the standalone `mcp_rails` gem.
- `rolemodel:testing:all` installs the Jasmine/Playwright runner only with `--js-runner`, instead of
  asking.
- Icon builders live in `lib/rolemodel/optics` under a `Rolemodel::Optics` module, and the Icon
  generator installs an `IconBuilder` into the app only when asked.
- `Rolemodel::Utility::TaskTools`, helpers for writing rake tasks.
- The README's `rails new` command passes `--skip-solid`.

## [v1.0.0] Mar 18, 2026

- Finishes the plugin rework from 0.26.0.
- The GitHub generator's CI workflow is reworked, and a Dependabot config generator joins it.
- The Playwright helper for generated system tests is reworked.
- Example apps are built with Rails' `AppGenerator` (`dummy_app: true`), the way Rails' own plugin
  generator builds its test app.

## [v0.26.0] Mar 1, 2026

The first release on RubyGems.

- The gem is `rolemodel-rails`, following the `-rails` convention of `rspec-rails` and
  `slim-rails`, under a single `Rolemodel` namespace in place of `RolemodelRails`.
- A Rails engine lets the host app discover the generators lazily instead of loading them at boot.

[v2.4.1]: https://github.com/RoleModel/rolemodel_rails/releases/tag/v2.4.1
[v2.4.0]: https://github.com/RoleModel/rolemodel_rails/releases/tag/v2.4.0
[v2.3.2]: https://github.com/RoleModel/rolemodel_rails/releases/tag/v2.3.2
[v2.3.1]: https://github.com/RoleModel/rolemodel_rails/releases/tag/v2.3.1
[v2.3.0]: https://github.com/RoleModel/rolemodel_rails/releases/tag/v2.3.0
[v2.2.0]: https://github.com/RoleModel/rolemodel_rails/releases/tag/v2.2.0
[v2.1.0]: https://github.com/RoleModel/rolemodel_rails/releases/tag/v2.1.0
[v2.0.1]: https://github.com/RoleModel/rolemodel_rails/releases/tag/v2.0.1
[v1.0.0]: https://github.com/RoleModel/rolemodel_rails/releases/tag/v1.0.0
[v0.26.0]: https://github.com/RoleModel/rolemodel_rails/releases/tag/v0.26.0
