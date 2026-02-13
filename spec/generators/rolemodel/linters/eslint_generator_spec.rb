RSpec.describe Rolemodel::Linters::EslintGenerator, type: :generator do
  before { run_generator_against_test_app }

  let(:eslint_script) { Rolemodel::Linters::EslintGenerator::ESLINT_COMMAND }
  let(:dev_dependencies) { Rolemodel::Linters::EslintGenerator::DEV_DEPENDENCIES }

  it 'adds eslint dev dependencies to package.json' do
    assert_file 'package.json' do |content|
      expect(JSON.parse(content)['devDependencies'].keys).to include(*dev_dependencies)
    end
  end

  it 'adds eslint script to package.json' do
    assert_file 'package.json' do |content|
      expect(JSON.parse(content).dig('scripts', 'eslint')).to eq eslint_script
    end
  end

  it 'adds eslint.config.js file' do
    assert_file 'eslint.config.js'
  end
end
