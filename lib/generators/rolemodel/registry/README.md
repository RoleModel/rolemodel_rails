# Registry Generator

One-time seeding tool for apps that were set up before the rolemodel_rails
generator registry existed. It probes for the characteristic output files of
each generator in the suite and writes detection-based entries into your app's
`config/initializers/rolemodel_generators.rb`.

## How it works

The seeder checks for known file artifacts that each generator creates — for
example, `webpack.config.js` for the webpack generator,
`config/initializers/sentry.rb` for sentry, `Procfile` for heroku. When it
finds one, it writes a `g.rolemodel <key>: true` entry with a `seeded-by-detection`
comment.

Entries from genuine generator runs (carrying a `rolemodel_rails X.Y.Z` version
stamp) are **never overwritten**. The seeder also never writes `false` entries.

## Running it

```
rails generate rolemodel:registry
```

Review the output carefully. Any generator that shows "not detected" may still
have been applied (some generators leave no reliable file footprint). Check
those manually and add entries by hand if needed.

## Re-running

Re-running is a no-op that reports current state. Already-seeded entries are
skipped; genuinely recorded entries are untouched.
