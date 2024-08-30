require 'spec_helper'
require 'generators/rolemodel/tailored_select/tailored_select_generator'

RSpec.describe Rolemodel::TailoredSelectGenerator, type: :generator do
  destination File.expand_path('tmp/', File.dirname(__FILE__))

  before(:all) do
    prepare_test_app
    FileUtils.cd(destination_root) { run_generator }
  end

  after(:all) do
    cleanup_test_app
  end

  it 'adds tailored select to package.json' do
    assert_file 'package.json' do |content|
      expect(content).to include('"@rolemodel/tailored-select":')
    end
  end
end
