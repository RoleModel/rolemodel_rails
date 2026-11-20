# FileContentHelper's methods are private and need a generator, so the method examples call them on one.
# Only those groups set up a test app with `type: :generator`. The matcher examples only parse strings.
RSpec.describe Rolemodel::FileContentHelper do
  def generator(options = {})
    Rolemodel::LogrageGenerator.new([], options, destination_root:)
  end

  def write(relative_path, content)
    path = File.join(destination_root, relative_path)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, content)
  end

  describe '#append_to_block', type: :generator do
    def append(code, matcher: Rolemodel::FileContentHelper::RAILS_APPLICATION_CLASS, **options)
      capture(:stdout) { generator(options).send(:append_to_block, 'example.rb', code, matcher) }
    end

    it 'adds the code as the last lines of the block, one level deeper than its end, in order' do
      write 'example.rb', <<~RUBY
        module Example
          class Application < Rails::Application
            config.a = 1
          end
        end
      RUBY

      append("config.b = 2\n")
      append("if true\n  config.c = 3\nend\n")

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

    it 'skips code the file already has' do
      write 'example.rb', "class Application < Rails::Application\nend\n"

      2.times { append("config.a = 1\n") }

      assert_file 'example.rb', "class Application < Rails::Application\n  config.a = 1\nend\n"
    end

    it 'finds the right end when other code follows the block' do
      write 'example.rb', "class Application < Rails::Application\nend\n\n# A comment\nclass Other\nend\n"

      append("config.a = 1\n")

      assert_file 'example.rb', "class Application < Rails::Application\n  config.a = 1\nend\n\n# A comment\nclass Other\nend\n"
    end

    it 'puts the code in the right place when non-ASCII text comes before the block' do
      write 'example.rb', "# Café — settings\nclass Application < Rails::Application\nend\n"

      append("config.a = 1\n")

      assert_file 'example.rb', "# Café — settings\nclass Application < Rails::Application\n  config.a = 1\nend\n"
    end

    it 'does not write the file with --pretend' do
      write 'example.rb', "class Application < Rails::Application\nend\n"

      append("config.a = 1\n", pretend: true)

      assert_file 'example.rb', "class Application < Rails::Application\nend\n"
    end

    it 'raises when no block matches' do
      write 'example.rb', "class Application < Other::Application\nend\n"

      expect { append("config.a = 1\n") }
        .to raise_error(Thor::Error, 'Could not find `class Application < Rails::Application` with `end` on its own line in example.rb')
    end

    it 'raises when the matching block closes on the same line it opens' do
      write 'example.rb', "Rails.application.configure do end\n"

      expect { append("config.a = 1\n", matcher: Rolemodel::FileContentHelper::RAILS_CONFIGURE_BLOCK) }
        .to raise_error(Thor::Error, 'Could not find `Rails.application.configure do` with `end` on its own line in example.rb')
    end
  end

  describe 'BlockMatcher' do
    matchers = Rolemodel::FileContentHelper.constants
                                       .map { Rolemodel::FileContentHelper.const_get(it) }
                                       .grep(Rolemodel::FileContentHelper::BlockMatcher)

    it 'has matchers to check' do
      expect(matchers).not_to eq []
    end

    matchers.each do |matcher|
      it "matches its own example: #{matcher}" do
        expect(matcher.find_in(matcher.example)).to be_truthy
      end
    end
  end

  describe 'RAILS_APPLICATION_CLASS' do
    let(:matcher) { Rolemodel::FileContentHelper::RAILS_APPLICATION_CLASS }

    it 'matches a class of any name that inherits from ::Rails::Application' do
      expect(matcher.find_in("class MyApp < ::Rails::Application\nend")).to be_truthy
    end

    it 'does not match a class with another parent, or none' do
      expect(matcher.find_in("class Application < Other::Application\nend")).to be_falsey
      expect(matcher.find_in("class Application < Foo::Rails::Application\nend")).to be_falsey
      expect(matcher.find_in("class Application\nend")).to be_falsey
    end
  end

  describe 'RAILS_CONFIGURE_BLOCK' do
    let(:matcher) { Rolemodel::FileContentHelper::RAILS_CONFIGURE_BLOCK }

    it 'does not match a look-alike call, or configure with no block' do
      expect(matcher.find_in("Other.application.configure do\nend")).to be_falsey
      expect(matcher.find_in('Rails.application.configure')).to be_falsey
    end
  end

  describe '#append_to_class', type: :generator do
    it 'adds the code as the last lines of the named class, not a class whose name starts the same' do
      write 'app/models/user.rb', "class UserPolicy\nend\n\nclass User < ApplicationRecord\n  devise :database_authenticatable,\n         :recoverable\nend\n"

      capture(:stdout) { generator.send(:append_to_class, 'app/models/user.rb', 'User', "\nenum :role, { user: 'user' }\n") }

      assert_file 'app/models/user.rb',
                  "class UserPolicy\nend\n\nclass User < ApplicationRecord\n  devise :database_authenticatable,\n         :recoverable\n\n  enum :role, { user: 'user' }\nend\n"
    end

    it 'names the class in the error when the file has no such class' do
      write 'app/models/user.rb', "class Account\nend\n"

      expect { capture(:stdout) { generator.send(:append_to_class, 'app/models/user.rb', 'User', "x = 1\n") } }
        .to raise_error(Thor::Error, 'Could not find `class User` with `end` on its own line in app/models/user.rb')
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
