require 'spec_helper'
require 'generators/rolemodel/ui_components/modals/modals_generator'

RSpec.describe Rolemodel::UiComponents::ModalsGenerator, type: :generator do
  destination File.expand_path('../tmp/', File.dirname(__FILE__))

  before { run_generator_against_test_app }

  it 'adds the correct javascript files' do
    assert_file 'app/javascript/controllers/toggle_controller.js'
    assert_file 'app/javascript/initializers/turbo_confirm.js'
    assert_file 'app/javascript/initializers/frame_missing_handler.js'
    assert_file 'app/javascript/initializers/before_morph_handler.js'
  end

  it 'correctly appends to the application.js file' do
    assert_file 'app/javascript/application.js' do |content|
      expect(content).to include("import './initializers/turbo_confirm.js'")
      expect(content).to include("import './initializers/frame_missing_handler.js'")
      expect(content).to include("import './initializers/before_morph_handler.js'")
    end
  end

  it 'correctly adds view templates' do
    assert_file 'app/views/layouts/modal.html.slim'
    assert_file 'app/views/layouts/panel.html.slim'
    assert_file 'app/views/application/_confirm.html.slim'
  end
end
