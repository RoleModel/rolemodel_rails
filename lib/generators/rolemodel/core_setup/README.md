# Core Setup Generator

Runs the core generators every new Rails app should have. Unlike
`rolemodel:all`, this skips the app-specific extras (React, SaaS/Devise,
GoodJob, Kaminari, etc.) so you get just the standard baseline — a new Rails
app you can push straight to Heroku right after generation.

## Prerequisites

  - A freshly generated Rails app

## What you get

  - [GitHub](../github) — standard GitHub configuration
  - [Heroku](../heroku) — standard Heroku deployment configuration
  - [Readme](../readme) — standard project README
  - [Webpack](../webpack) — Webpack v5 for JS and CSS
  - [Sentry](../sentry) — error monitoring for Ruby and JavaScript
  - [Slim](../slim) — Slim templates
  - [Optics](../optics) — Optics design system
  - [Testing](../testing) — RSpec, FactoryBot, parallel_tests, TestProf
    (pass `--js-runner` to include jasmine-playwright-runner)
  - [SimpleForm](../simple_form) — SimpleForm with our configuration
  - [Linters](../linters) — Rubocop and ESLint
  - [UI Components](../ui_components) — flash, the modal pattern, & Turbo 8 support
  - [Editors](../editors) — EditorConfig and recommended VSCode extensions
  - [Lograge](../lograge) — condensed request logging
