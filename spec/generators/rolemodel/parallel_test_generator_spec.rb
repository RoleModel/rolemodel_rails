require 'spec_helper'

RSpec.describe Rolemodel::Testing::ParallelTestsGenerator, type: :generator do
  before { run_generator_against_test_app }

  it 'adds the gems, adds .rspec_parallel, and edits the database.yml' do
    assert_file 'Gemfile' do |content|
      expect(content).to include('gem "parallel_tests"')
      expect(content).to include('gem "turbo_tests", require: false')
      expect(content).to include('gem "rspec_junit_formatter", require: false')
    end

    assert_file '.rspec_parallel'

    assert_file 'config/database.yml' do |content|
      expect(content.scan(/database:.*_test/).size).to eq(1) # Ensure old test database name is removed
      expect(content).to match(/database:.*_test<%= ENV\['TEST_ENV_NUMBER'\] %>/)
    end
  end
end
