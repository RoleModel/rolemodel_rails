require 'spec_helper'

RSpec.describe Rolemodel::SimpleFormGenerator, type: :generator do
  before { run_generator_against_test_app }

  it 'generates a simple form initializer' do
    assert_file 'config/initializers/simple_form.rb'
  end

  it 'generates custom input files' do
    assert_file 'app/inputs/collection_check_boxes_input.rb'
    assert_file 'app/inputs/collection_select_input.rb'
    assert_file 'app/inputs/grouped_collection_select_input.rb'
    assert_file 'app/inputs/segmented_control_input.rb'
    assert_file 'app/inputs/switch_checkbox_input.rb'
    assert_file 'app/inputs/tailored_select_input.rb'
  end
end
