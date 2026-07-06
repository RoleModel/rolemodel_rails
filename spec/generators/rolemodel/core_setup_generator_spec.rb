RSpec.describe Rolemodel::CoreSetupGenerator do
  let(:invocations) { [] }

  def invoke_core_setup(args = [])
    generator = described_class.new([], args)
    allow(generator).to receive(:generate) { |*invocation| invocations << invocation }
    generator.invoke_all
  end

  it 'runs the core generators in order' do
    invoke_core_setup

    expect(invocations).to eq [
      ['rolemodel:github'],
      ['rolemodel:heroku'],
      ['rolemodel:readme'],
      ['rolemodel:webpack'],
      ['rolemodel:sentry'],
      ['rolemodel:slim'],
      ['rolemodel:optics:all'],
      ['rolemodel:testing:all'],
      ['rolemodel:simple_form'],
      ['rolemodel:linters:all'],
      ['rolemodel:ui_components:flash'],
      ['rolemodel:ui_components:modals'],
      ['rolemodel:lograge']
    ]
  end
end
