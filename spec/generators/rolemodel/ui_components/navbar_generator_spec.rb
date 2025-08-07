# frozen_string_literal: true

require 'spec_helper'
require 'generators/rolemodel/ui_components/navbar/navbar_generator'

RSpec.describe Rolemodel::UiComponents::NavbarGenerator, type: :generator do
  destination File.expand_path('tmp/', File.dirname(__FILE__))
  let(:run_flash_generator_first) { false }

  before do
    FileUtils.cd(destination_root) do
      args = [['--force'], { behavior: :invoke, destination_root: destination_root }]
      Rails::Generators.invoke('rolemodel:slim', *args)
      Rails::Generators.invoke('rolemodel:webpack', *args)
      Rails::Generators.invoke('rolemodel:ui_components:flash', *args) if run_flash_generator_first
    end
    run_generator_against_test_app
  end

  it 'adds the navbar file' do
    assert_file 'app/views/layouts/_navbar.html.slim'
    assert_file 'app/javascript/lib/shoelace.js'
    assert_file 'app/assets/stylesheets/components/shoelace/index.scss'

    assert_file 'app/views/layouts/application.html.slim' do |content|
      expect(content).to include("= render 'layouts/navbar'")
    end

    assert_file 'app/assets/stylesheets/application.scss' do |content|
      expect(content).to include("@import 'components/shoelace/index.scss';")
    end

    assert_file 'app/javascript/application.js' do |content|
      expect(content).to include("import './lib/shoelace.js'")
    end
  end

  context 'if the flash has already been installed' do
    let(:run_flash_generator_first) { true }

    it 'places the render below flash' do
      assert_file 'app/views/layouts/application.html.slim' do |content|
        flash_index = content.index("= render 'layouts/flash'")
        navbar_index = content.index("= render 'layouts/navbar'")
        expect(flash_index).to be < navbar_index
      end
    end
  end
end
