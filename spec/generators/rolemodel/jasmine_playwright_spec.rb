require 'spec_helper'

RSpec.describe Rolemodel::Testing::JasminePlaywrightGenerator, type: :generator do
  before { run_generator_against_test_app }

  let(:node_version) { Rolemodel::Testing::JasminePlaywrightGenerator::NODE_VERSION }
  let(:test_script_content) { Rolemodel::Testing::JasminePlaywrightGenerator::TEST_COMMAND }

  it 'sets the node version' do
    assert_file '.node-version' do |content|
      expect(content).to eq(node_version)
    end
  end

  it 'adds test:browser script to package.json' do
    assert_file 'package.json' do |content|
      expect(content).to include("\"test:browser\": \"#{test_script_content}\"")
    end
  end

  it 'adds dev dependencies to package.json' do
    assert_file 'package.json' do |content|
      content_hash = JSON.parse(content)
      expect(content_hash['devDependencies']).to include('playwright')
      expect(content_hash['devDependencies']).to include('lit-html')
      # expect(content_hash['devDependencies']).to include('@rolemodel/jasmine-playwright-runner')
    end
  end
end
