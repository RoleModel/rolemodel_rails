require 'spec_helper'

RSpec.describe Rolemodel::Linters::RubocopGenerator, type: :generator do
  before { run_generator_against_test_app }

  it 'adds the correct helpers' do
    assert_file '.rubocop.yml'
    assert_file 'lib/cops/form_error_response.rb'
    assert_file 'lib/cops/no_chrome_tag.rb'
  end
end
