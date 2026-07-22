RSpec.describe Rolemodel::Linters::RubocopGenerator, type: :generator do
  before { run_generators }

  it 'adds the correct helpers' do
    assert_file '.rubocop.yml'
    assert_file '.rubocop/cops/form_error_response.rb'
    assert_file '.rubocop/cops/no_chrome_tag.rb'
  end
end
