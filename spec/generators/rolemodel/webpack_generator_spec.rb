RSpec.describe Rolemodel::WebpackGenerator, type: :generator do
  before { run_generator_against_test_app }

  let(:dev_dependencies) { Rolemodel::WebpackGenerator::DEV_DEPS }

  it 'adds the correct files' do
    assert_file '.node-version' do |content|
      expect(content).to eq Rolemodel::NODE_VERSION
    end
    assert_file 'postcss.config.cjs'
    assert_file 'webpack.config.js'
    assert_file 'app/assets/stylesheets/application.scss'
  end

  it 'adds webpack dev dependencies to package.json' do
    assert_file 'package.json' do |content|
      expect(JSON.parse(content)['devDependencies'].keys).to include(*dev_dependencies)
    end
  end

  it 'pins the project to Yarn 4+ via Corepack' do
    assert_file 'package.json' do |content|
      expect(JSON.parse(content)['packageManager']).to eq "yarn@#{Rolemodel::YARN_VERSION}"
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
    before { run_generator_against_test_app(['--sentry']) }

    it 'wires the Sentry plugin into webpack.config.js' do
      assert_file 'webpack.config.js' do |content|
        expect(content).to include("import { sentryWebpackPlugin } from '@sentry/webpack-plugin'")
        expect(content).to include('sentryWebpackPlugin({')
        expect(content).to include('].filter(Boolean)')
      end
    end
  end
end
