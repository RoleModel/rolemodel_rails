# RoleModel Rails

Executable Best Practices for Rails apps, based on RoleModel's best approaches

Attempts to solve the pain of:

* Setup of a new Rails app is harder than it needs to be
  * We've tried application templates, but only useful onetime
* Our BestPractice learns don't often get ported into other projects as it isn't straightforward to do so
* There is an emerging pattern of libraries using generators (e.g. webpacker) to migrate a setup between library versions

## Precondition

The rolemodel_rails gem expects to be added to an existing Rails project. Typically those are started with:

```shell
rails new <app-name> --javascript=webpack --css=sass --database=postgresql --skip-test
```

The Devise generator requires your database to exist before running.

```shell
rails db:create
```

## Installation

Add this line to your application's Gemfile:

```ruby
group :development do
  gem 'rolemodel_rails', github: 'RoleModel/rolemodel_rails'
end
```

And then execute:

    $ bundle

## Usage

Run all generators (useful on a new app)

```shell
bin/rails g rolemodel:all
```

Or run a single generator

```shell
bin/rails g rolemodel:webpack
```

Or run a category subset

```shell
bin/rails g rolemodel:testing:all
```

You can see complete list of available generators (including those under the RoleModel namespace) by running

```shell
bin/rails g
```

## Generators

* [Github](./lib/generators/rolemodel/github)
* [Semaphore](./lib/generators/rolemodel/semaphore)
* [Heroku](./lib/generators/rolemodel/heroku)
* [Readme](./lib/generators/rolemodel/readme)
* [Webpack](./lib/generators/rolemodel/webpack)
* [React](./lib/generators/rolemodel/react)
* [Slim](./lib/generators/rolemodel/slim)
* [Optics](./lib/generators/rolemodel/optics)
  * [Base](./lib/generators/rolemodel/optics/base)
  * [Icons](./lib/generators/rolemodel/optics/icons)
* [Testing](./lib/generators/rolemodel/testing)
  * [RSpec](./lib/generators/rolemodel/testing/rspec)
  * [Factory Bot](./lib/generators/rolemodel/testing/factory_bot)
  * [Test Prof](./lib/generators/rolemodel/testing/test_prof)
* [SimpleForm](./lib/generators/rolemodel/simple_form)
* [SoftDestroyable](./lib/generators/rolemodel/soft_destroyable)
* [SaaS](./lib/generators/rolemodel/saas)
  * [Devise](./lib/generators/rolemodel/saas/devise)
* [Mailers](./lib/generators/rolemodel/mailers)
* [Linters](./lib/generators/rolemodel/linters)
  * [Rubocop](./lib/generators/rolemodel/linters/rubocop)
  * [ESLint](./lib/generators/rolemodel/linters/eslint)
* [Modals](./lib/generators/rolemodel/modals)
* [Source Map](./lib/generators/rolemodel/source_map)
* [Kaminari](./lib/generators/rolemodel/kaminari)
* [GoodJob](./lib/generators/rolemodel/good_job)
* [Editors](./lib/generators/rolemodel/editors)

## Development

Install the versions of Node and Ruby specified in `.node-version` and `.ruby-version` on your machine. https://asdf-vm.com/ is a great tool for managing language versions. Then run `npm install -g yarn`.

We use the embeded Rails apps [Rails 7 Example](./recreate_rails7_example) to test the usage of the generators.

`recreate_rails7_example` is simply a freshly generated Rails 7 app. To recreate it use:

```shell
bin/recreate_rails7_example
```

Then, cd into `example_rails7` and run a rolemodel generator to see how it affects a new Rails 7 project. For example:

```shell
cd example_rails7
bin/rails g rolemodel:webpack
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/RoleModel/rolemodel_rails.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
