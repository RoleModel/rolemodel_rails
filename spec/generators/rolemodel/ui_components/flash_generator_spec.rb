# frozen_string_literal: true

require 'spec_helper'
require 'generators/rolemodel/ui_components/flash/flash_generator'

RSpec.describe Rolemodel::UiComponents::FlashGenerator, type: :generator do
  destination File.expand_path('tmp/', File.dirname(__FILE__))

  before do
    FileUtils.cd(destination_root) do
      args = [['--force'], { behavior: :invoke, destination_root: destination_root }]
      Rails::Generators.invoke('rolemodel:slim', *args)
    end
    run_generator_against_test_app
  end

  it 'adds the flash file' do
    assert_file 'app/views/layouts/_flash.html.slim'
    assert_file 'spec/support/matchers/flash_matchers.rb'

    assert_file 'app/views/layouts/application.html.slim' do |content|
      expect(content).to include("= render 'layouts/flash'")
    end
  end
end
