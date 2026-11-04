RSpec.describe Rolemodel::CoreSetupGenerator do
  it 'passes the chosen icon library through to the optics generators' do
    generator = described_class.new([], ['--material'])
    allow(generator).to receive(:generate)

    generator.run_the_core_generators

    expect(generator).to have_received(:generate).with('rolemodel:optics:all', '--material')
  end

  it 'installs the skills for the rolemodel_rails utilities' do
    generator = described_class.new
    allow(generator).to receive(:install_skill)

    generator.install_agent_skills

    expect(generator).to have_received(:install_skill).with('polymorphic-parent-resources')
    expect(generator).to have_received(:install_skill).with('rake-tasks')
  end
end
