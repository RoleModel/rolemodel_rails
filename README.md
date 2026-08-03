# RoleModel Rails

Executable Best Practices for Rails apps, based on RoleModel's best approaches

Attempts to solve the pain of:

* Setup of a new Rails app is harder than it needs to be
  * We've tried application templates, but only useful onetime
* Our BestPractice learns don't often get ported into other projects as it isn't straightforward to do so
* There is an emerging pattern of libraries using generators (e.g. webpacker) to migrate a setup between library versions

## Precondition

The rolemodel-rails gem expects to be added to an existing Rails project. Typically those are started with:

```shell
rails new <app-name> --javascript=webpack --database=postgresql --skip-test --skip-solid
```

The Devise generator requires your database to exist before running.

```shell
rails db:create
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rolemodel-rails'
```

> [!IMPORTANT]
> We used to recommend putting rolemodel-rails in the development gem group. This is no longer supported, because some Rolemodel namespaced utility modules and classes are expected to be available at runtime.

And then execute:

    $ bundle install

## Usage

Run the core generators (recommended on a new app — sets up our standard
baseline so the app is ready to push straight to Heroku)

```shell
bin/rails g rolemodel:core_setup
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

* [Core Setup](./lib/generators/rolemodel/core_setup)
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
* [Turbo](./lib/generators/rolemodel/turbo)
  * [Ready](./lib/generators/rolemodel/turbo/ready)
  * [Confirm](./lib/generators/rolemodel/turbo/confirm)
  * [Modals](./lib/generators/rolemodel/turbo/modals)
  * [Form](./lib/generators/rolemodel/turbo/form)
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
  * [Navbar](./lib/generators/rolemodel/ui_components/navbar)
* [Source Map](./lib/generators/rolemodel/source_map)
* [Kaminari](./lib/generators/rolemodel/kaminari)
* [GoodJob](./lib/generators/rolemodel/good_job)
* [Editors](./lib/generators/rolemodel/editors)
* [Tailored Select](./lib/generators/rolemodel/tailored_select)
* [Lograge](./lib/generators/rolemodel/lograge)

## Utilities

### `Rolemodel::Utility::TaskTools`

A mixin of helper methods for writing friendlier, more informative Rake tasks. It provides consistent, migration-style console output, progress indication for long-running loops, an opt-in dry-run mode, and sanitized positional task arguments.

#### Requiring & Including

The module is available at runtime (rolemodel-rails must not be restricted to the `development` gem group). Require it and `include` it inside the `namespace` block of your `.rake` file:

```ruby
require 'rolemodel/utility/task_tools'

namespace :reports do
  include Rolemodel::Utility::TaskTools

  task total: :environment do
    @total = GeneratedReport.count
  end

  namespace :clear do
    desc 'Delete all non-current report records'
    task expired: :total do
      say_with_time "Detecting & Deleting Expired Reports among #{@total} Total" do
        deleted_reports = 0
        GeneratedReport.find_each.with_index do |report, index|
          indicate_progress(index, @total)
          next if report.current?

          report.destroy unless dry_run?
          deleted_reports += 1
        end
        say "#{deleted_reports}/#{@total} Records Deleted"
      end
    end
  end
end
```

> [!NOTE]
> `include` inside a `namespace` block adds the helper methods to the anonymous object that evaluates your task bodies, making them (and any plain methods you define alongside them) available to every task in that namespace.

#### Helper Methods

##### `say(message)`

Prints a message using the same style as Rails migrations. Pass `subitem: true` to indent the line beneath a preceding `say`.

```ruby
say 'Doing some important stuff!'
say 'Like this one specific thing!', subitem: true
#=> -- Doing some important stuff!
#=>    -> Like this one specific thing!
```

##### `say_with_time(message, &block)`

Wraps `say` and prints the block's real execution time as an indented subitem. Use it to announce and time a unit of work.

```ruby
say_with_time "Deleting all #{@total} Records" do
  GeneratedReport.destroy_all unless dry_run?
end
#=> -- Deleting all 42 Records
#=>    -> 0.0198s
```

##### `indicate_progress(index, total = nil, report_interval: 9)`

Renders an animated spinner (and, when `total` is given, a completion percentage) for a long-running loop. Call it once per iteration with the current index; it only redraws every `report_interval` iterations so the animation stays eye-trackable. Pass a reduced `report_interval` when iterations are very slow.

```ruby
GeneratedReport.find_each.with_index do |report, index|
  indicate_progress(index, @total)
  # ...
end
```

##### `dry_run?`

Returns `true` when the `DRY_RUN` environment variable is present, enabling a dry-run pattern for your tasks. Guard any code that writes to the database or file system with `unless dry_run?` so the task still produces its console feedback without performing the side effects.

```ruby
report.destroy unless dry_run?
```

```shell
DRY_RUN=true rake reports:clear:expired
```

##### `sanitize_arguments(args, defaults = {})`

Improves the usability of positional `Rake::Task` arguments, which cannot declare default values and are awkward to skip. Pass the task's `args` and a hash of defaults; it returns a hash with whitespace stripped, blank/skipped values (passed as `_`) replaced by your defaults.

```ruby
desc 'Seed a dev user with the given name and email'
task :dev, %i[name email] => :environment do |_, args|
  name, email = sanitize_arguments(args, name: 'RoleModel', email: 'it-support@rolemodelsoftware.com').values_at(:name, :email)
  say_with_time "Seeding Dev User (name: #{name}, email: #{email}, role: Admin)" do
    User.find_or_create(name:, email:, role: 'admin') unless dry_run?
  end
end
```

```shell
# Skip the name argument with `_` to fall back to its default
DRY_RUN=true rake users:dev[_,bob@example.com]
#=> -- Seeding Dev User (name: RoleModel, email: bob@example.com, role: Admin)
#=>    -> 0.0000s
```

### `Rolemodel::ResourceFor::ControllerExtension`

Provides the private `resource_for` utility method to all controller classes throughout your app. Use it in conjunction with Routing concerns.

#### The Problem It Solves

Apps accumulate resources that hang off many different parents. Good examples include `comments`, `reports`, `duplications`.

The naive approach involves many namespaced controllers that all do the same thing but with a different parent resource, or adding several non-restful actions to each parent controller.

The following example illustrates a better pattern.

##### Routing

Declare the child resource inside a route concern and pass the parent's class name as a route default using `parent_resource`:

```ruby
concern :commentable do
  resources :comments, commentable_type: parent_resource.name.classify
end

concern :reportable do
  resources :generated_reports, only: %i[show create], reportable_type: parent_resource.name.classify
end

shallow do
  resources :accounts do
    resources :estimates, concerns: %i[commentable reportable] do
      resources :widgets, concerns: %i[commentable reportable]
    end
  end
end
```

##### Controller

One controller serves every parent:

```ruby
class CommentsController < ApplicationController
  before_action :set_commentable, only: %i[index new create]
  before_action :set_comment, except: %i[index new create]

  def create
    # ...
  end

  private

  def set_commentable
    @commentable = resource_for(:commentable_type) # pass in the symbol specified in your routing concern.
  end
end
```

Under `shallow: true`, only the collection actions (`index`, `new`, `create`) carry the parent id — hence the `only:`/`except:` split above. Member actions find the child directly by `params[:id]` and reach the parent through its own association.

`resource_for` returns the record itself, so it composes with authorization and presentation:

```ruby
def set_resource
  @resource = authorize resource_for(:resource_type)
end
```

#### Guarding User-Supplied Types

Route defaults are merged into `params` last, so a route-supplied type cannot be overridden by a query string or request body. If a type ever arrives from user input instead, allowlist it before calling `resource_for` — `safe_constantize` will happily resolve any constant in the app:

```ruby
REPORT_CONTEXTS = %w[Accessory Estimate PartProxy Tank].freeze

before_action :verify_context_type, :set_context, only: %i[create]

private

def verify_context_type
  return if REPORT_CONTEXTS.include?(params[:context_type])

  redirect_back_or_to root_url, alert: 'Invalid Request'
end
```

Doing this even for route-supplied types is cheap insurance: it documents which parents the controller actually supports and fails loudly when a new route wires up a parent the controller cannot handle.

#### Notes

* Raises `ActiveRecord::RecordNotFound` when the id does not resolve, which Rails renders as a 404 — the same behavior as any other `find`.
* `safe_constantize` returns `nil` for an unknown constant, producing a `NoMethodError`; allowlisting avoids that.
* The class name is demodulized when deriving the id param, so `Reporting::Tank` looks for `params[:tank_id]`.
* Included via `ActiveSupport.on_load(:action_controller_base)`, so `ActionController::API` controllers do not get it.

## Development

Install the versions of Node and Ruby specified in `.node-version` and `.ruby-version` on your machine. https://asdf-vm.com/ is a great tool for managing language versions. Then run `corepack enable` to activate the Yarn 4+ version pinned by each project's `packageManager` field.

## Adding new Generators

Run `bin/new_generator` passing the **name** you want to use and a **description**.  Consult the list of existing [Generators](#generators) in case your new generator belongs in one of the existing groups (folders).

e.g.

```shell
bin/new_generator testing/fantasitic_specs 'A Fantastic Testing Framework'
```

We use the embeded Rails apps (`example_rails_current` & `example_rails_legacy`) to test generators against. They reference the rolemodel-rails gem by local path,
so you can navigate into one of them and run your generator for immediate feedback while developing.

## Testing

Generator specs should be added to the [spec](./spec) directory.

Setup & Teardown of the test-dummy app is handled for you.  All you need to do is run the provided helper method:

e.g.

```ruby
RSpec.describe Rolemodel::MyGenerator, type: :generator do
  before { run_generators }
end
```

You may also provide command line arguments to the helper method as an array:

e.g.

```ruby
RSpec.describe Rolemodel::Testing::JasminePlaywrightGenerator, type: :generator do
  before { run_generators(['--github-package-token=123']) }
end
```

If the generator you're testing depends on being run after another generator, you may pass an array to the optional `generators` keyword argument in the order in which they should run.

e.g.

```ruby
RSpec.describe Rolemodel::MyGenerator, type: :generator do
  before do
    run_generators(generators: [::Rolemodel::PrereqGenerator, described_class])
  end
end
```

If you're testing the standard output produced by your generator, assign the return value of `run_generators` to a variable.

e.g.

```ruby
RSpec.describe Rolemodel::MyGenerator, type: :generator do
  before do
    @stdout = run_generators(generators: [::Rolemodel::PrereqGenerator, described_class])
  end

  it 'prints something useful' do
    expect(@stdout[Rolemodel::MyGenerator]).to include('something useful')
  end
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
