RSpec.describe Rolemodel::Turbo::FormGenerator, type: :generator do
  before { run_generators(generators:) }
  let(:generators) { [::Rolemodel::SlimGenerator, ::Rolemodel::WebpackGenerator, described_class] }

  it 'adds the turbo_form gem' do
    assert_file 'Gemfile' do |content|
      expect(content).to include('turbo_form')
    end
  end

  it 'runs the turbo_form installer' do
    assert_file 'app/javascript/application.js' do |content|
      expect(content).to include('@rolemodel/turbo-form')
    end
  end

  it 'installs the dynamic-forms skill' do
    assert_file '.agents/skills/dynamic-forms/SKILL.md'
  end
end
