require 'spec_helper'
require 'generators/rolemodel/modals/modals_generator'

RSpec.describe Rolemodel::ModalsGenerator, type: :generator do
  destination File.expand_path('tmp/', File.dirname(__FILE__))

  before { run_generator_against_test_app }

  it 'installs Turbo Confirm package' do
    assert_file 'yarn.lock' do |content|
      expect(content).to include('@rolemodel/turbo-confirm')
    end
  end

  it 'generates views & link helpers' do
    assert_file 'app/helpers/turbo_frame_link_helper.rb'
    assert_file 'app/views/layouts/modal.html.slim'
    assert_file 'app/views/layouts/panel.html.slim'
    assert_file 'app/views/application/_confirm.html.slim'
  end

  it 'generates & imports javascript files' do
    assert_file 'app/javascript/controllers/toggle_controller.js'
    assert_file 'app/javascript/initializers/turbo_confirm.js'
    assert_file 'app/javascript/initializers/frame_missing_handler.js'

    assert_file 'app/javascript/application.js' do |content|
      expect(content).to include("import './initializers/turbo_confirm'")
      expect(content).to include("import './initializers/frame_missing_handler'")
    end
  end
end
