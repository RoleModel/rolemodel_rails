RSpec.describe Rolemodel::TomSelectGenerator, type: :generator do
  it 'adds tom-select to package.json' do
    run_generators

    assert_file 'package.json' do |content|
      expect(content).to include('"tom-select":')
    end
  end

  it 'imports the tom-select stylesheet' do
    run_generators

    assert_file 'app/assets/stylesheets/application.css' do |content|
      expect(content).to include("@import 'tom-select/dist/css/tom-select.css';")
    end
  end

  it 'registers the stimulus controller' do
    run_generators

    assert_file 'app/javascript/controllers/tom_select_controller.js'
    assert_file 'app/javascript/controllers/index.js' do |content|
      expect(content).to include('application.register("tom-select", TomSelectController)')
    end
  end

  it 'does not install the SimpleForm inputs when SimpleForm is absent' do
    run_generators

    assert_no_file 'app/inputs/tom_select_input.rb'
  end

  it 'installs the SimpleForm inputs when SimpleForm is present' do
    run_generators generators: [::Rolemodel::SimpleFormGenerator, described_class]

    assert_file 'app/inputs/tom_select_input.rb'
    assert_file 'app/inputs/grouped_tom_select_input.rb'
  end
end
