RSpec.describe Rolemodel::AllGenerator, type: :generator do
  # Each sub-generator is exercised by its own spec, so here we only verify
  # which generators get delegated to (and in what order).
  let(:invoked_generators) { [] }

  before do
    # Stub on the Actions module rather than the generator class: stubbing the
    # class defines a new public method on it, which Thor would then pick up as
    # an additional command to run.
    allow_any_instance_of(Rails::Generators::Actions).to receive(:generate) do |_instance, name, *|
      invoked_generators << name
    end

    run_generators
  end

  it 'delegates to every rolemodel generator in order' do
    expect(invoked_generators).to eq([
      'rolemodel:github',
      'rolemodel:heroku',
      'rolemodel:readme',
      'rolemodel:webpack',
      'rolemodel:sentry',
      'rolemodel:react',
      'rolemodel:slim',
      'rolemodel:optics:all',
      'rolemodel:testing:all',
      'rolemodel:simple_form',
      'rolemodel:soft_destroyable',
      'rolemodel:saas:all',
      'rolemodel:mailers',
      'rolemodel:linters:all',
      'rolemodel:ui_components:all',
      'rolemodel:source_map',
      'rolemodel:good_job',
      'rolemodel:kaminari',
      'rolemodel:editors',
      'rolemodel:lograge'
    ])
  end

  it 'only delegates to generators that exist' do
    unknown = invoked_generators.reject { |name| Rails::Generators.find_by_namespace(name) }

    expect(unknown).to eq([])
  end

  it 'does not delegate to tailored_select, which is not production ready' do
    expect(invoked_generators).not_to include('rolemodel:tailored_select')
  end

  it 'does not delegate to a semaphore generator' do
    expect(invoked_generators).not_to include(a_string_matching(/semaphore/))
  end
end
