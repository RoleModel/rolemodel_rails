# frozen_string_literal: true

require 'spec_helper'
require 'generators/rolemodel/jasmine_playwright/jasmine_playwright_generator'

RSpec.describe Rolemodel::JasminePlaywrightGenerator, type: :generator do
  destination File.expand_path('tmp/', File.dirname(__FILE__))

  before do
    run_generator_against_test_app
  end

  it 'adds the correct files' do
    assert_file '.node-version'
    assert_file 'spec/javascript/browser/support/react.mjs'
    assert_file 'spec/javascript/browser/example_spec.js'
  end
end
