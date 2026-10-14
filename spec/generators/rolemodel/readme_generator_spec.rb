RSpec.describe Rolemodel::ReadmeGenerator, type: :generator do
  it 'replaces the README Rails generated without stopping to ask' do
    expect(Thor::LineEditor).not_to receive(:readline)

    run_generators

    assert_file 'README.md', /# Overview/
  end
end
