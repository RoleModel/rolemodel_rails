# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Rolemodel::WebpackGenerator, type: :generator do
  before { run_generator_against_test_app }

  it 'adds the correct files' do
    assert_file '.node-version'
  end
end
