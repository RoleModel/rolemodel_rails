RSpec.describe Rolemodel::CoreSetupGenerator, type: :generator do
  let(:invoked_generators) { [] }

  before do
    allow_any_instance_of(Rails::Generators::Actions).to receive(:generate) do |_instance, name, *|
      invoked_generators << name
    end

    run_generators
  end

  it 'installs tom_select after simple_form' do
    expect(invoked_generators.index('rolemodel:tom_select')).to eq(invoked_generators.index('rolemodel:simple_form') + 1)
  end
end
