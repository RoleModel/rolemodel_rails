RSpec.describe Rolemodel::TailoredSelectGenerator, type: :generator do
  before { run_generator_against_test_app }

  it 'adds tailored select to package.json' do
    assert_file 'package.json' do |content|
      expect(content).to include('"@rolemodel/tailored-select":')
    end
  end
end
