RSpec.describe Rolemodel::AllGenerator, type: :generator do
  # Each sub-generator is exercised by its own spec, so here we only verify
  # which generators get delegated to.
  let(:invoked_generators) { [] }
  let(:generators_root) { File.expand_path('../../../lib/generators/rolemodel', __dir__) }
  let(:excluded_generators) do
    {
      'rolemodel:core_setup' => 'a subset of rolemodel:all',
      'rolemodel:tailored_select' => 'not production ready'
    }
  end

  # A directory with its own all generator is delegated to as a group.
  def generators_on_disk
    Dir.children(generators_root).select { File.directory?(File.join(generators_root, it)) }.map do |dir|
      grouped = Dir.exist?(File.join(generators_root, dir, 'all')) || File.exist?(File.join(generators_root, dir, 'all_generator.rb'))
      grouped ? "rolemodel:#{dir}:all" : "rolemodel:#{dir}"
    end
  end

  before do
    # Stub on the Actions module rather than the generator class: stubbing the
    # class defines a new public method on it, which Thor would then pick up as
    # an additional command to run.
    allow_any_instance_of(Rails::Generators::Actions).to receive(:generate) do |_instance, name, *|
      invoked_generators << name
    end

    run_generators
  end

  it 'delegates to every generator on disk that is not excluded' do
    expect(invoked_generators).to match_array(generators_on_disk - excluded_generators.keys)
  end
end
