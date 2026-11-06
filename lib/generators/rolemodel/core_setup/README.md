# Core Setup Generator

[USAGE](./USAGE)

Runs the core generators every new Rails app should have. Unlike
`rolemodel:all`, this skips the app-specific extras (React, SaaS/Devise,
GoodJob, Kaminari, etc.) so you get just the standard baseline — a new Rails
app you can push straight to Heroku right after generation.

## Prerequisites

  - A freshly generated Rails app

## Options

  - `--material`, `--phosphor`, `--tabler`, `--feather`, `--lucide`, or `--custom`
    picks the Optics icon library up front. Without one, the icons generator asks.
  - `--skip-deployable` skips Heroku, Sentry, and Lograge.

## What you get

  - [Slim](../slim) — Slim templates
  - [Webpack](../webpack) — Webpack v5 for JS and CSS
  - [Optics](../optics) — Optics design system and icons
  - [SimpleForm](../simple_form) — SimpleForm with our configuration
  - [Tom Select](../tom_select) — Tom Select with a Stimulus controller and SimpleForm inputs
  - [Testing](../testing) — RSpec, FactoryBot, parallel_tests, and TestProf
  - [Turbo](../turbo) — Turbo 8 setup, confirm dialogs, modals, and dynamic forms
  - [Flash](../ui_components/flash) — flash messages
  - [GitHub](../github) — standard GitHub configuration
  - [Readme](../readme) — standard project README
  - [Linters](../linters) — Rubocop and ESLint
  - [Heroku](../heroku) — standard Heroku deployment configuration
  - [Sentry](../sentry) — error monitoring for Ruby and JavaScript
  - [Lograge](../lograge) — condensed request logging
  - The [`polymorphic-parent-resources`](https://github.com/RoleModel/skills/tree/main/skills/polymorphic-parent-resources)
    and [`rake-tasks`](https://github.com/RoleModel/skills/tree/main/skills/rake-tasks) agent skills for
    `resource_for` and `Rolemodel::Utility::TaskTools`, installed into `.agents/skills`
