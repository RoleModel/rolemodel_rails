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
      ['rolemodel:slim'],
      ['rolemodel:webpack'],
      ['rolemodel:optics:all'],
      ['rolemodel:simple_form'],
      ['rolemodel:testing:all'],
      ['rolemodel:turbo:all'],
      ['rolemodel:ui_components:flash'],
      ['rolemodel:github'],
      ['rolemodel:heroku'],
      ['rolemodel:readme'],
      ['rolemodel:sentry'],
      ['rolemodel:linters:all'],
      ['rolemodel:lograge']
    ]
  end
end
