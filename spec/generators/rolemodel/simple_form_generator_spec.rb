RSpec.describe Rolemodel::SimpleFormGenerator, type: :generator do
  it 'generates a simple form initializer' do
    run_generators_against_test_app

    assert_file 'config/initializers/simple_form.rb'
  end

  it 'generates the default custom input files' do
    run_generators_against_test_app

    assert_file 'app/inputs/collection_check_boxes_input.rb'
    assert_file 'app/inputs/collection_select_input.rb'
    assert_file 'app/inputs/grouped_collection_select_input.rb'
    assert_file 'app/inputs/segmented_control_input.rb'
    assert_file 'app/inputs/switch_checkbox_input.rb'
  end

  it 'generates slim scaffold templates for simple form' do
    run_generators_against_test_app

    assert_file 'lib/templates/slim/scaffold/_form.html.slim' do |content|
      expect(content).to include("<%=")
      expect(content).not_to include("<%%=")
    end
  end

  context 'the --tailored_select option' do
    let(:invocations) { [] }

    def invoke_simple_form(args = [])
      generator = described_class.new([], args)
      allow(generator).to receive(:generate) { |*invocation| invocations << invocation }
      # Stub the parts that touch the filesystem/network; we only care about
      # whether the tailored_select generator is delegated to.
      %i[add_gem add_files].each { |step| allow(generator).to receive(step) }
      generator.invoke_all
    end

    it 'delegates to the tailored_select generator when passed' do
      invoke_simple_form(['--tailored_select'])

      expect(invocations).to include(['rolemodel:tailored_select'])
    end

    it 'does not delegate to the tailored_select generator by default' do
      invoke_simple_form

      expect(invocations).not_to include(['rolemodel:tailored_select'])
    end
  end
end
