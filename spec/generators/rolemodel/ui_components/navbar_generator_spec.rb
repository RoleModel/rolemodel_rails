# frozen_string_literal: true

require 'spec_helper'
require 'generators/rolemodel/ui_components/navbar/navbar_generator'

RSpec.describe Rolemodel::UiComponents::NavbarGenerator, type: :generator do
  destination File.expand_path('tmp/', File.dirname(__FILE__))

  before do
    FileUtils.cd(destination_root) do
      args = [['--force'], { behavior: :invoke, destination_root: destination_root }]
      Rails::Generators.invoke('rolemodel:slim', *args)
      Rails::Generators.invoke('rolemodel:webpack', *args)
      # Rails::Generators.invoke('rolemodel:optics:base', *args)
    end
    run_generator_against_test_app
  end

  it 'adds the navbar file' do
    # binding.irb
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
end
