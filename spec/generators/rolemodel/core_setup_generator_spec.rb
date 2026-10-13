RSpec.describe Rolemodel::CoreSetupGenerator do
  it 'passes the chosen icon library through to the optics generators' do
    generator = described_class.new([], ['--material'])
    allow(generator).to receive(:generate)

    generator.run_the_core_generators

    expect(generator).to have_received(:generate).with('rolemodel:optics:all', '--material')
  end
end
