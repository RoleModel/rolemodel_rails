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
rails new <app-name> --javascript=webpack --database=postgresql --skip-test
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
  * [Jasmine Playwright](./lib/generators/rolemodel/testing/jasmine_playwright)
  * [ViTest](./lib/generators/rolemodel/testing/vitest)
  * [Factory Bot](./lib/generators/rolemodel/testing/factory_bot)
  * [Test Prof](./lib/generators/rolemodel/testing/test_prof)
  * [Parallel Test](./lib/generators/rolemodel/testing/parallel_tests)
* [SimpleForm](./lib/generators/rolemodel/simple_form)
* [SoftDestroyable](./lib/generators/rolemodel/soft_destroyable)
* [SaaS](./lib/generators/rolemodel/saas)
  * [Devise](./lib/generators/rolemodel/saas/devise)
* [Mailers](./lib/generators/rolemodel/mailers)
* [Linters](./lib/generators/rolemodel/linters)
  * [Rubocop](./lib/generators/rolemodel/linters/rubocop)
  * [ESLint](./lib/generators/rolemodel/linters/eslint)
* [UI Components](./lib/generators/rolemodel/ui_components)
  * [Flash](./lib/generators/rolemodel/ui_components/flash)
  * [Modals](./lib/generators/rolemodel/ui_components/modals)
  * [Navbar](./lib/generators/rolemodel/ui_components/navbar)
* [Source Map](./lib/generators/rolemodel/source_map)
* [Kaminari](./lib/generators/rolemodel/kaminari)
* [GoodJob](./lib/generators/rolemodel/good_job)
* [Editors](./lib/generators/rolemodel/editors)
* [Tailored Select](./lib/generators/rolemodel/tailored_select)
* [Lograge](./lib/generators/rolemodel/lograge)

## Development

Install the versions of Node and Ruby specified in `.node-version` and `.ruby-version` on your machine. https://asdf-vm.com/ is a great tool for managing language versions. Then run `npm install -g yarn`.

We use the embeded Rails apps (`example_rails*`) to test generators against. They reference the rolemodel_rails gem by local path,
so you can navigate into one of them and run your generator for immediate feedback while developing.

> [!IMPORTANT]
> Before submitting a PR, run `bin/bump_version` to ensure the Gem builds successfully & that everything continues to stay in sync & up-to-date.<br /><br />
> For very small changes & bug fixes, prefer `bin/bump_version --patch`.

## Testing

Generator specs should be added to the [spec](./spec) directory.

Setup & Teardown of the test-dummy app is handled for you.  All you need to do is run the provided helper method:

e.g.

```ruby
RSpec.describe Rolemodel::MyGenerator, type: :generator do
  before { run_generator_against_test_app }
end
```

You may also provide command line arguments to the helper method as an array:

e.g.

```ruby
RSpec.describe Rolemodel::Testing::JasminePlaywrightGenerator, type: :generator do
  before { run_generator_against_test_app(['--github-package-token=123']) }
end
```

Additional information about testing generators and the available assertions & matchers can be found at the following resources.

* [Rails Guide](https://guides.rubyonrails.org/generators.html#testing-generators)
* [API Documentation](https://api.rubyonrails.org/classes/Rails/Generators/Testing/Assertions.html)
* [Generator Spec Gem](https://github.com/stevehodgkiss/generator_spec)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/RoleModel/rolemodel_rails.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
