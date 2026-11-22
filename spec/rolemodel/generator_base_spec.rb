RSpec.describe Rolemodel::GeneratorBase, type: :generator do
  def generator
    Rolemodel::LogrageGenerator.new([], [], destination_root:)
  end

  describe '#add_setting' do
    it 'runs rolemodel:dotenv when the app has no EnvValue', env_value: false do
      instance = generator
      allow(instance).to receive(:invoke)

      capture(:stdout) { instance.send(:add_setting, "config.x.a = EnvValue.string('A')") }

      expect(instance).to have_received(:invoke).with('rolemodel:dotenv', [], anything)
    end

    it 'adds each setting as the last line of the Application class, in order' do
      capture(:stdout) { generator.send(:add_setting, "config.x.a = EnvValue.string('A')") }
      capture(:stdout) { generator.send(:add_setting, "config.x.b = EnvValue.string('B')") }

      assert_file 'config/application.rb' do |content|
        expect(content).to end_with(
          "    config.x.a = EnvValue.string('A')\n    config.x.b = EnvValue.string('B')\n  end\nend\n"
        )
      end
    end
  end

  describe '#add_default_url' do
    def add_default_url
      FileUtils.cd(destination_root) { capture(:stdout) { generator.send(:add_default_url) } }
    end

    it 'sets email and route URLs from DEFAULT_URL at the end of the Application class' do
      add_default_url

      assert_file 'config/application.rb' do |content|
        expect(content).to include("    config.x.default_url = EnvValue.url('DEFAULT_URL') do\n")
        expect(content).to include("    config.action_mailer.default_url_options = { host: config.x.default_url }\n")
        expect(content).to end_with(
          "    Rails.application.routes.default_url_options = config.action_mailer.default_url_options\n  end\nend\n"
        )
      end
    end

    it 'comments out the development and production default_url_options, which would win over it' do
      add_default_url

      %w[development production].each do |env|
        assert_file "config/environments/#{env}.rb" do |content|
          expect(content).to match(/^\s*# config\.action_mailer\.default_url_options = /)
          expect(content).not_to match(/^\s*config\.action_mailer\.default_url_options = /)
        end
      end
      assert_file 'config/environments/test.rb', /^\s*config\.action_mailer\.default_url_options = /
    end

    it 'changes nothing the second time, as when mailers and devise both run' do
      2.times { add_default_url }

      assert_file 'config/application.rb' do |content|
        expect(content.scan("config.x.default_url = EnvValue.url('DEFAULT_URL')").size).to eq 1
      end
      assert_file 'config/environments/production.rb' do |content|
        expect(content).not_to include('# # config.action_mailer.default_url_options')
      end
    end
  end
end
