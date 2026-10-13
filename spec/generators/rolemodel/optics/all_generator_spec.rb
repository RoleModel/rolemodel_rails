RSpec.describe Rolemodel::Optics::AllGenerator do
  it 'passes the chosen icon library to the icons generator instead of leaving it to prompt' do
    generator = described_class.new([], ['--phosphor'])
    allow(generator).to receive(:generate)

    generator.run_all_the_generators

    expect(generator).to have_received(:generate).with('rolemodel:optics:icons', '--phosphor')
  end
end
