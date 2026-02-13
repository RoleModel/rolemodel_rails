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
    assert_file 'app/javascript/initializers/honeybadger.js'
  end

  it 'adds webpack dev dependencies to package.json' do
    assert_file 'package.json' do |content|
      expect(JSON.parse(content)['devDependencies'].keys).to include(*dev_dependencies)
    end
  end
end
