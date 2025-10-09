require 'spec_helper'

RSpec.describe Rolemodel::GithubGenerator, type: :generator do
  before do
    respond_to_prompt with: 'a' # prompt for overriding ci.yml
    run_generator_against_test_app
  end

  it 'creates github pull request template' do
    assert_file '.github/pull_request_template.md' do |content|
      expect(content).not_to include('Update version number in `lib/rolemodel_rails/version.rb`')
    end

    assert_file '.github/instructions/css.instructions.md'
    assert_file '.github/instructions/js.instructions.md'
    assert_file '.github/instructions/project.instructions.md'
    assert_file '.github/instructions/ruby.instructions.md'
    assert_file '.github/instructions/slim.instructions.md'
  end

  it 'creates ci.yml and updates the database.yml' do
    assert_file '.github/workflows/ci.yml' do |content|
      expect(content).to include('Linting & Ruby Non-System Tests')
    end

    assert_file 'config/database.yml' do |content|
      expect(content).to include('  username: <%= ENV.fetch("POSTGRES_USER") %>')
      expect(content).to include('  password: <%= ENV.fetch("POSTGRES_PASSWORD") { nil } %>')
      expect(content).to include('  host: localhost')
    end
  end
end
