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
end
