RSpec.describe Rolemodel::CoreSetupGenerator do
  let(:invocations) { [] }

  def build_generator(args = [], &stub)
    described_class.new([], args).tap do |generator|
      allow(generator).to receive(:generate) do |*invocation|
        invocations << invocation
        stub&.call(invocation)
      end
    end
  end

  def invoke_core_setup(args = [], &stub)
    build_generator(args, &stub).invoke_all
  end

  it 'runs the core generators in order without the removed --sentry flag' do
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

  it 'does not invoke the removed semaphore generator' do
    invoke_core_setup

    expect(invocations).not_to include(['rolemodel:semaphore'])
  end

  it 'aborts the whole run when a child generator fails' do
    expect do
      invoke_core_setup do |invocation|
        raise SystemExit if invocation == ['rolemodel:webpack']
      end
    end.to raise_error(SystemExit)

    # Children after the failing one never run.
    expect(invocations).to eq [
      ['rolemodel:github'],
      ['rolemodel:heroku'],
      ['rolemodel:readme'],
      ['rolemodel:webpack']
    ]
  end

  it 'is exempt from registry recording (it is a composite)' do
    expect(described_class.skip_registry_entry?).to be(true)
  end
end
