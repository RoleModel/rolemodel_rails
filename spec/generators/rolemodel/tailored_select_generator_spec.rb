RSpec.describe Rolemodel::TailoredSelectGenerator, type: :generator do
  it 'adds tailored select to package.json' do
    run_generator_against_test_app

    assert_file 'package.json' do |content|
      expect(content).to include('"@rolemodel/tailored-select":')
    end
  end

  it 'does not install the SimpleForm input by default (SimpleForm not recorded)' do
    run_generator_against_test_app

    assert_no_file 'app/inputs/tailored_select_input.rb'
  end

  it 'installs the SimpleForm input when passed --simple-form-input' do
    run_generator_against_test_app(['--simple-form-input'])

    assert_file 'app/inputs/tailored_select_input.rb'
  end
end
