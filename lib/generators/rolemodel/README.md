# RoleModel Generator

[USAGE](./USAGE)

## What you get

* [Github](./github)
* [GoodJob](./good_job)
* [Heroku](./heroku)
* [Linters](./linters)
* [Mailers](./mailers)
* [Modals](./modals)
* [Optics](./optics)
* [README](./readme)
* [SaaS](./saas)
* [SimpleForm](./simple_form)
* [Slim](./slim)
* [SoftDestroyable](./soft_destroyable)
* [Source Map](./source_map)
* [Testing](./testing)
* [Webpack](./webpack)
* [Registry](./registry)

## Generator Registry

Each generator records itself in `config/initializers/rolemodel_generators.rb`
so that other generators can detect whether it has been applied. See
[Registry](./registry) for the seeding tool.

### Generator coupling

Some generators declare optional couplings:

* **sentry ↔ webpack:** Whichever is installed second wires the Sentry webpack
  plugin into `webpack.config.js` via the `sentry_webpack` hook sub-generator.
  Pass `--no-sentry-webpack` to suppress. Set
  `g.rolemodel sentry_webpack: false` in the initializer for a persistent opt-out.
* **tailored_select ↔ simple_form:** Installing simple_form with
  `--tailored-select` installs the tailored_select package and its input.
  Installing tailored_select standalone installs the package without the input.
  Pass `--simple-form-input` to force the input regardless.

## Helpful documentation

* [Rails Custom Generators](https://guides.rubyonrails.org/generators.html)
* [Generator Action Methods](https://api.rubyonrails.org/classes/Rails/Generators/Actions.html)
* [Thor Action Methods](https://www.rubydoc.info/github/erikhuda/thor/master/Thor/Actions)
Thor action methods can be used just like Rails generator action methods
