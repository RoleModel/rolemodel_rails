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
end
