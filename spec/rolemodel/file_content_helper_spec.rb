# FileContentHelper's methods are private and need a generator, so the method examples call them on one.
# Only those groups set up a test app with `type: :generator`. The matcher examples only parse strings.
RSpec.describe Rolemodel::FileContentHelper do
  def generator(options = {})
    Rolemodel::LogrageGenerator.new([], options, destination_root:)
  end

  def app_class = Rolemodel::FileContentHelper::BlockMatcher.for_class(superclass: 'Rails::Application')
  def configure_block = Rolemodel::FileContentHelper::BlockMatcher.for_call(:Rails, :application, :configure)

  def write(relative_path, content)
    path = File.join(destination_root, relative_path)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, content)
  end

  describe '#inject_into_block', type: :generator do
    def inject(data, matcher: app_class, generator_options: {}, **config)
      capture(:stdout) do
        generator(generator_options).send(:inject_into_block, 'example.rb', matcher, data, config)
      end
    end

    it 'with at: :end, adds the data just before the end, as given, in order' do
      write 'example.rb', <<~RUBY
        module Example
          class Application < Rails::Application
            config.a = 1
          end
        end
      RUBY

      inject("    config.b = 2\n", at: :end)
      inject("    if true\n      config.c = 3\n    end\n", at: :end)

      assert_file 'example.rb', <<~RUBY
        module Example
          class Application < Rails::Application
            config.a = 1
            config.b = 2
            if true
              config.c = 3
            end
          end
        end
      RUBY
    end

    it 'by default, adds the data right after the opening line, even when it wraps' do
      write 'example.rb', "Rails.application.configure do |config,\n                               other|\n  config.a = 1\nend\n"

      inject("  config.b = 2\n", matcher: configure_block)

      assert_file 'example.rb', "Rails.application.configure do |config,\n                               other|\n  config.b = 2\n  config.a = 1\nend\n"
    end

    it 'takes the data from a block, as Thor does' do
      write 'example.rb', "class Application < Rails::Application\nend\n"

      capture(:stdout) do
        generator.send(:inject_into_block, 'example.rb', app_class) { "  config.a = 1\n" }
      end

      assert_file 'example.rb', "class Application < Rails::Application\n  config.a = 1\nend\n"
    end

    it 'skips data the file already has' do
      write 'example.rb', "class Application < Rails::Application\nend\n"

      2.times { inject("  config.a = 1\n", at: :end) }

      assert_file 'example.rb', "class Application < Rails::Application\n  config.a = 1\nend\n"
    end

    it 'finds the right end when other code follows the block' do
      write 'example.rb', "class Application < Rails::Application\nend\n\n# A comment\nclass Other\nend\n"

      inject("  config.a = 1\n", at: :end)

      assert_file 'example.rb', "class Application < Rails::Application\n  config.a = 1\nend\n\n# A comment\nclass Other\nend\n"
    end

    it 'puts the data in the right place when non-ASCII text comes before the block' do
      write 'example.rb', "# Café — settings\nclass Application < Rails::Application\nend\n"

      inject("  config.a = 1\n", at: :end)

      assert_file 'example.rb', "# Café — settings\nclass Application < Rails::Application\n  config.a = 1\nend\n"
    end

    it 'does not write the file with --pretend' do
      write 'example.rb', "class Application < Rails::Application\nend\n"

      inject("  config.a = 1\n", generator_options: { pretend: true })

      assert_file 'example.rb', "class Application < Rails::Application\nend\n"
    end

    it 'raises when no block matches' do
      write 'example.rb', "class Application < Other::Application\nend\n"

      expect { inject("  config.a = 1\n") }
        .to raise_error(Thor::Error, 'Could not find `class Example < Rails::Application` with `end` on its own line in example.rb')
    end

    it 'raises when the matching block closes on the same line it opens' do
      write 'example.rb', "Rails.application.configure do end\n"

      expect { inject("  config.a = 1\n", matcher: configure_block) }
        .to raise_error(Thor::Error, 'Could not find `Rails.application.configure do` with `end` on its own line in example.rb')
    end

    it 'rejects an unknown at: value' do
      write 'example.rb', "class Application < Rails::Application\nend\n"

      expect { inject("x = 1\n", at: :middle) }.to raise_error(ArgumentError, /at: must be :start or :end/)
    end
  end

  describe 'BlockMatcher' do
    matcher_class = Rolemodel::FileContentHelper::BlockMatcher
    [
      matcher_class.for_class(superclass: 'Rails::Application'),
      matcher_class.for_class(name: 'User'),
      matcher_class.for_class(name: 'User', superclass: 'ApplicationRecord'),
      matcher_class.for_module('Reports'),
      matcher_class.for_call(:Rails, :application, :configure)
    ].each do |matcher|
      it "matches its own example: #{matcher}" do
        expect(matcher.find_in(matcher.example)).to be_truthy
      end
    end
  end

  describe 'BlockMatcher.for_call' do
    let(:matcher_class) { Rolemodel::FileContentHelper::BlockMatcher }
    let(:matcher) { matcher_class.for_call(:Rails, :application, :configure) }

    it 'matches the same call chain with a block, with or without a leading ::, and with any arguments' do
      expect(matcher.find_in("::Rails.application.configure do\nend")).to be_truthy
      expect(matcher.find_in("Rails.application.configure(:x) do |config|\nend")).to be_truthy
    end

    it 'does not match a different chain, a longer or shorter one, or a call with no block' do
      expect(matcher.find_in("Rails.app.configure do\nend")).to be_falsey
      expect(matcher.find_in("Foo::Rails.application.configure do\nend")).to be_falsey
      expect(matcher.find_in("application.configure do\nend")).to be_falsey
      expect(matcher.find_in('Rails.application.configure')).to be_falsey
    end

    it 'works for other calls, such as routes, and names itself after the chain' do
      routes = matcher_class.for_call(:Rails, :application, :routes, :draw)

      expect(routes.find_in("Rails.application.routes.draw do\n  root 'home#show'\nend")).to be_truthy
      expect(routes.to_s).to eq 'Rails.application.routes.draw do'
    end

    it 'takes a namespaced constant, or no constant for a call with no receiver' do
      settings = matcher_class.for_call('Admin::Settings', :configure)
      bare = matcher_class.for_call(:configure)

      expect(settings.find_in("::Admin::Settings.configure do\nend")).to be_truthy
      expect(bare.find_in("configure do\nend")).to be_truthy
      expect(bare.find_in("Rails.configure do\nend")).to be_falsey
    end

    it 'needs at least one name' do
      expect { matcher_class.for_call }.to raise_error(ArgumentError, /needs at least one name/)
    end
  end

  describe 'BlockMatcher.for_class' do
    it 'matches a class by its name as written, not a class whose name starts the same' do
      matcher = Rolemodel::FileContentHelper::BlockMatcher.for_class(name: 'User')

      expect(matcher.find_in("class UserPolicy\nend\nclass User<ApplicationRecord\nend")&.constant_path&.slice).to eq 'User'
      expect(matcher.find_in("# class User\nclass Account\nend")).to be_falsey
    end

    it 'matches a class by its superclass, with or without a leading ::' do
      matcher = Rolemodel::FileContentHelper::BlockMatcher.for_class(superclass: 'ApplicationRecord')

      expect(matcher.find_in("class User < ::ApplicationRecord\nend")).to be_truthy
      expect(matcher.find_in("class User < Struct.new(:x)\nend")).to be_falsey
      expect(matcher.find_in("class User < foo::ApplicationRecord\nend")).to be_falsey
    end

it 'matches any class name under Rails::Application, and not another parent or none' do
      expect(app_class.find_in("class MyApp < ::Rails::Application\nend")).to be_truthy
      expect(app_class.find_in("class Application < Other::Application\nend")).to be_falsey
      expect(app_class.find_in("class Application < Foo::Rails::Application\nend")).to be_falsey
      expect(app_class.find_in("class Application\nend")).to be_falsey
    end

    it 'matches by both name and superclass' do
      matcher = Rolemodel::FileContentHelper::BlockMatcher.for_class(name: 'User', superclass: 'ApplicationRecord')

      expect(matcher.find_in("class User < Base\nend")).to be_falsey
      expect(matcher.find_in("class User < ApplicationRecord\nend")).to be_truthy
      expect(matcher.to_s).to eq 'class User < ApplicationRecord'
    end
  end

  describe '#inject_into_class', type: :generator do
    let(:user_rb) { "# class User is below\nclass User < ApplicationRecord\n  devise :database_authenticatable,\n         :recoverable\nend\n" }

    def inject(*args, &block)
      capture(:stdout) do
        generator.send(:inject_into_class, 'app/models/user.rb', 'User', *args, &block)
      end
    end

    it 'adds the data right after the class line by default, as Thor does, skipping comments that mention the class' do
      write 'app/models/user.rb', user_rb

      inject("  include Searchable\n")

      assert_file 'app/models/user.rb', user_rb.sub("ApplicationRecord\n", "ApplicationRecord\n  include Searchable\n")
    end

    it 'adds the data just before the end with at: :end, from a block, without changing its indentation' do
      write 'app/models/user.rb', user_rb

      inject(at: :end) { "\n  enum :role, { user: 'user' }\n" }

      assert_file 'app/models/user.rb', user_rb.sub("\nend\n", "\n\n  enum :role, { user: 'user' }\nend\n")
    end

    it 'finds the class line when it wraps' do
      write 'app/models/user.rb', "class User <\n    ApplicationRecord\nend\n"

      inject("  include Searchable\n")

      assert_file 'app/models/user.rb', "class User <\n    ApplicationRecord\n  include Searchable\nend\n"
    end

    it 'raises when the file has no such class, or the class is on one line' do
      write 'app/models/user.rb', "class Account\nend\nclass User; end\n"

      expect { inject("x = 1\n") }
        .to raise_error(Thor::Error, 'Could not find `class User` with `end` on its own line in app/models/user.rb')
    end
  end

  describe '#inject_into_module', type: :generator do
    def inject(*args, &block)
      capture(:stdout) do
        generator.send(:inject_into_module, 'app/models/reports.rb', 'Reports', *args, &block)
      end
    end

    it 'adds the data right after the module line by default, and before the end with at: :end' do
      write 'app/models/reports.rb', "# module Reports\nmodule ReportsHelper\nend\n\nmodule Reports\n  NAME = 'x'\nend\n"

      inject("  extend self\n")
      inject("\n  def self.all = []\n", at: :end)

      assert_file 'app/models/reports.rb',
                  "# module Reports\nmodule ReportsHelper\nend\n\nmodule Reports\n  extend self\n  NAME = 'x'\n\n  def self.all = []\nend\n"
    end

    it 'names the module in the error when the file has no such module' do
      write 'app/models/reports.rb', "class Reports\nend\n"

      expect { inject("x = 1\n") }
        .to raise_error(Thor::Error, 'Could not find `module Reports` with `end` on its own line in app/models/reports.rb')
    end
  end

  describe '#modify_json_file', type: :generator do
    it 'reads a file with comments and trailing commas, as VS Code writes them' do
      write '.vscode/extensions.json', "{\n  // See https://go.microsoft.com/fwlink\n  \"recommendations\": [\"a.b\",],\n}\n"

      capture(:stdout) { generator.send(:modify_json_file, '.vscode/extensions.json') { it['recommendations'] << 'c.d' } }

      assert_file '.vscode/extensions.json' do |content|
        expect(JSON.parse(content)).to eq('recommendations' => %w[a.b c.d])
      end
    end
  end

  describe '#append_to_application', type: :generator do
    it 'adds the code as the last lines of the Rails::Application class' do
      capture(:stdout) { generator.send(:append_to_application, "config.x.a = 1\n") }

      assert_file 'config/application.rb' do |content|
        expect(content).to end_with("    config.x.a = 1\n  end\nend\n")
      end
    end
  end

  describe '#append_to_environment', type: :generator do
    it 'adds the code as the last lines of the Rails.application.configure block' do
      capture(:stdout) { generator.send(:append_to_environment, 'production', "config.x.a = 1\n") }

      assert_file 'config/environments/production.rb' do |content|
        expect(content).to end_with("  config.x.a = 1\nend\n")
      end
    end
  end
end
