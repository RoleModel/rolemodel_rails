# frozen_string_literal: true

require 'spec_helper'
require 'generators/rolemodel/optics/icons/icons_generator'

RSpec.describe Rolemodel::Optics::IconsGenerator, type: :generator do
  destination File.expand_path('tmp/', File.dirname(__FILE__))

  before do
    expect(Thor::LineEditor).to receive(:readline).and_return('phosphor') # prompt for icon library
    run_generator_against_test_app
  end

  it 'adds the correct helper and builders' do
    assert_file 'app/helpers/icon_helper.rb'
    assert_file 'app/icon_builders/icon_builder.rb'
    assert_file 'app/icon_builders/phosphor_icon_builder.rb'
  end
end
