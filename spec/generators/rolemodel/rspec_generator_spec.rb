require 'spec_helper'
require 'generators/rolemodel/testing/rspec/rspec_generator'

RSpec.describe Rolemodel::Testing::RspecGenerator, type: :generator do
  destination File.expand_path('tmp/', File.dirname(__FILE__))

  before { run_generator_against_test_app }

  it 'adds the correct helpers' do
    assert_file 'spec/support/helpers/action_cable_helper.rb'
    assert_file 'spec/support/helpers/select_helper.rb'
    assert_file 'spec/support/helpers/test_element_helper.rb'
    assert_file 'spec/support/helpers/playwright_helper.rb'
    assert_file 'spec/support/helpers/capybara_helper.rb'
  end
end
