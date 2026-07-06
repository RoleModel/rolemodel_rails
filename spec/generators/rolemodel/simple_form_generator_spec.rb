RSpec.describe Rolemodel::SimpleFormGenerator, type: :generator do
  it 'generates a simple form initializer' do
    allow_any_instance_of(Thor::Shell::Basic).to receive(:yes?).and_return(false)
    run_generator_against_test_app

    assert_file 'config/initializers/simple_form.rb'
  end

  it 'generates the default custom input files' do
    allow_any_instance_of(Thor::Shell::Basic).to receive(:yes?).and_return(false)
    run_generator_against_test_app

    assert_file 'app/inputs/collection_check_boxes_input.rb'
    assert_file 'app/inputs/collection_select_input.rb'
    assert_file 'app/inputs/grouped_collection_select_input.rb'
    assert_file 'app/inputs/segmented_control_input.rb'
    assert_file 'app/inputs/switch_checkbox_input.rb'
  end

  it 'generates slim scaffold templates for simple form' do
    allow_any_instance_of(Thor::Shell::Basic).to receive(:yes?).and_return(false)
    run_generator_against_test_app

    assert_file 'lib/templates/slim/scaffold/_form.html.slim' do |content|
      expect(content).to include("<%=")
      expect(content).not_to include("<%%=")
    end
  end

  context 'when the tailored_select input is declined' do
    before do
      allow_any_instance_of(Thor::Shell::Basic).to receive(:yes?).and_return(false)
      run_generator_against_test_app
    end

    it 'does not generate the tailored_select input' do
      assert_no_file 'app/inputs/tailored_select_input.rb'
    end
  end

  context 'when the tailored_select input is confirmed' do
    before do
      allow_any_instance_of(Thor::Shell::Basic).to receive(:yes?).and_return(true)
      run_generator_against_test_app
    end

    it 'generates the tailored_select input' do
      assert_file 'app/inputs/tailored_select_input.rb'
    end
  end
end
