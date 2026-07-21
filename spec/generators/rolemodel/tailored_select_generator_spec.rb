RSpec.describe Rolemodel::TailoredSelectGenerator, type: :generator do
  it 'adds tailored select to package.json' do
    run_generators

    assert_file 'package.json' do |content|
      expect(content).to include('"@rolemodel/tailored-select":')
    end
  end

  it 'does not install the SimpleForm input when SimpleForm is absent' do
    run_generators

    assert_no_file 'app/inputs/tailored_select_input.rb'
  end

  it 'installs the SimpleForm input when SimpleForm is present' do
    run_generators generators: [::Rolemodel::SimpleFormGenerator, described_class]

    assert_file 'app/inputs/tailored_select_input.rb'
  end
end
