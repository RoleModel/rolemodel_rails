require 'spec_helper'
require 'generators/rolemodel/testing/rspec/rspec_generator'

RSpec.describe Rolemodel::Testing::RspecGenerator, type: :generator do
  destination File.expand_path('tmp/', File.dirname(__FILE__))

  before(:all) do
    prepare_test_app
    run_generator
  end

  after(:all) do
    cleanup_test_app
  end

  it 'adds tailored select to package.json' do
    assert_file 'spec/support/helpers/action_cable_helper.rb'
    assert_file 'spec/support/helpers/select_helper.rb'
    assert_file 'spec/support/helpers/test_element_helper.rb'
  end
end
