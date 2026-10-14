RSpec.describe 'rolemodel-rails.gemspec' do
  let(:files) { Gem::Specification.load(File.expand_path('../rolemodel-rails.gemspec', __dir__)).files }

  it 'packages dotfile templates' do
    expect(files).to include(
      'lib/generators/rolemodel/linters/rubocop/templates/.rubocop.yml',
      'lib/generators/rolemodel/testing/rspec/templates/.rspec',
      'lib/generators/rolemodel/testing/parallel_tests/templates/.rspec_parallel'
    )
    cops = 'lib/generators/rolemodel/linters/rubocop/templates/.rubocop/cops/'
    expect(files).to include(a_string_starting_with(cops))
  end

  it 'packages no symlinks, which do not survive gem installation' do
    expect(files.select { File.symlink?(File.expand_path("../#{it}", __dir__)) }).to be_empty
  end
end
