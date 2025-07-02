require 'spec_helper'
require 'generators/rolemodel/linters/rubocop/rubocop_generator'

RSpec.describe Rolemodel::Linters::RubocopGenerator, type: :generator do
  destination File.expand_path('tmp/', File.dirname(__FILE__))

  before { run_generator_against_test_app }

  it 'adds the correct helpers' do
    assert_file '.rubocop.yml'
    assert_file 'lib/cops/form_error_response.rb'
    assert_file 'lib/cops/no_chrome_tag.rb'
  end
end
