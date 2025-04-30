# frozen_string_literal: true

require 'spec_helper'
require 'generators/rolemodel/webpack/webpack_generator'

RSpec.describe Rolemodel::WebpackGenerator, type: :generator do
  destination File.expand_path('tmp/', File.dirname(__FILE__))

  before do
    run_generator_against_test_app
  end

  it 'adds the correct files' do
    assert_file '.node-version'
  end
end
