RSpec.describe Rolemodel::WebpackGenerator, type: :generator do
  before { run_generators }

  let(:dev_dependencies) { Rolemodel::WebpackGenerator::DEV_DEPS }

  it 'adds the correct files' do
    assert_file '.node-version' do |content|
      expect(content).to eq Rolemodel::NODE_VERSION
    end
    assert_file 'postcss.config.cjs'
    assert_file 'webpack.config.js'
  end

  it 'adds webpack dev dependencies to package.json' do
    assert_file 'package.json' do |content|
      expect(JSON.parse(content)['devDependencies'].keys).to include(*dev_dependencies)
    end
  end

  it 'pins the project to Yarn 4+ via Corepack' do
    assert_file 'package.json' do |content|
      expect(JSON.parse(content)['packageManager']).to match(/^yarn@4\./)
    end

    assert_file '.yarnrc.yml' do |content|
      expect(content).to include('nodeLinker: node-modules')
    end

    assert_file '.gitignore' do |content|
      expect(content).to include('/.yarn/install-state.gz')
    end
  end

  it 'does not wire Sentry into webpack.config.js by default' do
    assert_file 'webpack.config.js' do |content|
      expect(content).not_to include('@sentry/webpack-plugin')
    end
  end

  context 'with the --sentry option' do
    # Stubbed on a single instance (rather than run against the test app)
    # because Thor treats any method RSpec defines on the class as a generator
    # action. The wiring itself is covered by the Sentry generator spec.
    def run_sentry_generator_action(args)
      invocations = []
      generator = described_class.new([], args)
      allow(generator).to receive(:generate) { |*invocation| invocations << invocation }
      generator.run_sentry_generator
      invocations
    end

    it 'runs the Sentry generator (which owns the webpack wiring)' do
      expect(run_sentry_generator_action(['--sentry'])).to eq [['rolemodel:sentry']]
    end

    it 'does not run the Sentry generator without the option' do
      expect(run_sentry_generator_action([])).to eq []
    end
  end
end
