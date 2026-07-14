RSpec.describe Rolemodel::Turbo::InstallGenerator, type: :generator do
  before { run_generator_against_test_app }

  it 'creates the correct directory structure for Stimulus controllers' do
    assert_directory 'app/javascript/controllers'
    assert_file 'app/javascript/controllers/index.js'
    assert_file 'app/javascript/controllers/application.js'
  end

  it 'creates a package.json file' do
    assert_file 'package.json'
  end

  it 'imports Turbo in the JavaScript entrypoint' do
    assert_file 'app/javascript/application.js' do |content|
      expect(content).to include("import \"@hotwired/turbo-rails\"")
    end
  end
end
