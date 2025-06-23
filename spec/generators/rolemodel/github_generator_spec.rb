# frozen_string_literal: true

require 'spec_helper'
require 'generators/rolemodel/github/github_generator'

RSpec.describe Rolemodel::GithubGenerator, type: :generator do
  destination File.expand_path('tmp/', File.dirname(__FILE__))

  before do
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
end
