require 'spec_helper'

RSpec.describe Rolemodel::UiComponents::ModalsGenerator, type: :generator do
  before do
    run_generator_against_test_app(generator: ::Rolemodel::SlimGenerator)
    run_generator_against_test_app(generator: ::Rolemodel::WebpackGenerator)
    run_generator_against_test_app(generator: ::Rolemodel::Optics::BaseGenerator)
    run_generator_against_test_app(command_line_options)
  end

  let(:command_line_options) { [] }

  it 'adds the correct javascript files' do
    assert_file 'app/javascript/controllers/toggle_controller.js'
    assert_file 'app/javascript/initializers/turbo_confirm.js'
    assert_file 'app/javascript/initializers/frame_missing_handler.js'
    assert_file 'app/javascript/initializers/before_morph_handler.js'
  end

  it 'imports initializers into application.js' do
    assert_file 'app/javascript/application.js' do |content|
      expect(content).to include("import './initializers/turbo_confirm.js'")
      expect(content).to include("import './initializers/frame_missing_handler.js'")
      expect(content).to include("import './initializers/before_morph_handler.js'")
    end
  end

  it 'adds the confirmation & shared head partials' do
    assert_file 'app/views/application/_confirm.html.slim'
    assert_file 'app/views/application/_head.html.slim'

    assert_file 'app/views/layouts/application.html.slim' do |content|
      expect(content).to match(/\s+head = render 'head'$/)
      expect(content).to match(/\s+= render 'confirm'$/)
    end
  end

  describe 'default options (--no-panel)' do
    it 'adds modal layout only' do
      assert_file 'app/views/layouts/modal.html.slim'
      assert_no_file 'app/views/layouts/panel.html.slim'
    end

    it 'updates application layout with modal turbo-frame' do
      assert_file 'app/views/layouts/application.html.slim' do |content|
        expect(content).to match(/\s+= turbo_frame_tag 'modal'$/)
        expect(content).not_to match(/\s+= turbo_frame_tag 'panel'$/)
      end
    end
  end

  describe 'with --panel option' do
    it 'adds modal & panel layouts' do
      assert_file 'app/views/layouts/modal.html.slim'
      assert_file 'app/views/layouts/panel.html.slim'
    end

    it 'updates application layout with modal & panel turbo-frames' do
      assert_file 'app/views/layouts/application.html.slim' do |content|
        expect(content).to match(/\s+= turbo_frame_tag 'modal'$/)
        expect(content).to match(/\s+= turbo_frame_tag 'panel'$/)
      end
    end
  end
end
