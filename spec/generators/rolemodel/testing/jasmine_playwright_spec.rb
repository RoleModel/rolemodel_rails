require 'spec_helper'

RSpec.describe Rolemodel::Testing::JasminePlaywrightGenerator, type: :generator do
  before do
    respond_to_prompt with: 'yes'
    run_generator_against_test_app(['--github-package-token=123'])
  end

  let(:test_script_content) { Rolemodel::Testing::JasminePlaywrightGenerator::TEST_COMMAND }

  it 'sets the node version' do
    assert_file '.node-version' do |content|
      expect(content).to eq Rolemodel::NODE_VERSION
    end
  end

  it 'adds test:browser script to package.json' do
    assert_file 'package.json' do |content|
      expect(content).to include("\"test:browser\": \"#{test_script_content}\"")
    end
  end
end
