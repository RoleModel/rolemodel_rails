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

    # Where the line goes is covered by the append_to_application spec.
    it 'adds the setting to config/application.rb' do
      capture(:stdout) { generator.send(:add_setting, "config.x.a = EnvValue.string('A')") }

      assert_file 'config/application.rb' do |content|
        expect(content).to include("config.x.a = EnvValue.string('A')")
      end
    end
  end
end
