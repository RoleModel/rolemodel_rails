# Webpacker Generator

Sets up Webpacker using curated set of templates maintained in this project. We do this instead of relying directly on the built in webpacker generators. Instead we leverage those to build our templates.

## What you get

* Webpacker
* Setup polyfills
* React (optional)
* Jest
* Default rake task including both RSpec and jest tests

## To recreate templates

Needed after new versions are released.

In [example_rails6](example_rails6)

```
rails g rolemodel:webpacker:dev
git add .
cd ..
git diff --name-only --staged
```

Copy into templates directory (scripted with `bin/copy_webpacker_templates`)

If config files are renamed `.babelrc` to `babel.config.js` our generator should now delete the old file if it exists in the project where run.
