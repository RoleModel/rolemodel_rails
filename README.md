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
rails new <app-name> --skip-test --database=postgresql
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
bin/rails g rolemodel:webpacker
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
* [Testing](./lib/generators/rolemodel/testing)
  * [RSpec](./lib/generators/rolemodel/testing/rspec)
  * [Factory Bot](./lib/generators/rolemodel/testing/factory_bot)
  * [Test Prof](./lib/generators/rolemodel/testing/test_prof)
* [Webpacker](./lib/generators/rolemodel/webpacker)
* [CSS](./lib/generators/rolemodel/css)
  * [Base](./lib/generators/rolemodel/css/base)
* [Readme](./lib/generators/rolemodel/readme)
* [Heroku](./lib/generators/rolemodel/heroku)
* [SaaS](./lib/generators/rolemodel/saas)
  * [Devise](./lib/generators/rolemodel/saas/devise)

## Development

We use the 2 embeded Rails apps [example](./example) and [example_with_webpacker](./example_with_webpacker) to test the usage of the generators.

`example` is simply a fresh generated Rails app. To recreate it (after Rails version changes, etc) use:

```shell
bin/recreate_example
```

Because Webpacker has so many moving parts, we want test bed where we can see the full [rolemodel:webpacker](./lib/generators/rolemodel/webpacker). To recreate it (after a version change, etc) use:

```shell
bin/recreate_webpacker_example
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/RoleModel/rolemodel_rails.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
