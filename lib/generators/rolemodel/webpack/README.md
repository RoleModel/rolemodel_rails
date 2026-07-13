# Webpack Generator

## What you get

* Webpack v5
* Uses `esbuild-loader` instead of Babel to transpile JS
* Uses PostCSS to compile CSS and SCSS

## Coupling with sentry

When `rolemodel:sentry` is already recorded in the app's generator registry,
running the webpack generator automatically wires the `sentryWebpackPlugin` into
the freshly created `webpack.config.js` via the shared `rolemodel:sentry_webpack`
hook sub-generator.

* Pass `--no-sentry-webpack` to suppress this wiring.
* Set `g.rolemodel sentry_webpack: false` in `config/initializers/rolemodel_generators.rb`
  for a persistent opt-out.
* If sentry is installed *after* webpack, running `rolemodel:sentry` will
  likewise wire the Sentry plugin automatically.
