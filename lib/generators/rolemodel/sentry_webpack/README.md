# Sentry Webpack Generator

Wiring-only hook sub-generator that injects the `sentryWebpackPlugin` into
`webpack.config.js` so production builds upload source maps to Sentry.

## Why it exists

The sentry and webpack generators are coupled: whichever one is installed
second should wire Sentry into the webpack config. Rather than duplicating that
wiring on both generators, both declare a `coupling_hook :sentry_webpack`, and
this sub-generator is the single shared target that does the wiring.

You normally never run this directly. It fires automatically when:

* you run `rolemodel:sentry` in an app where `rolemodel:webpack` is recorded, or
* you run `rolemodel:webpack` in an app where `rolemodel:sentry` is recorded.

Pass `--sentry-webpack` to force it, or `--no-sentry-webpack` to suppress it.

## Behavior

* Idempotent: a no-op when there is no `webpack.config.js` or the plugin is
  already wired.
* Not recorded in the registry — it is not an installable generator on its own.
* After running, update the `project` and `applicationKey` in
  `webpack.config.js` to match your Sentry project.
