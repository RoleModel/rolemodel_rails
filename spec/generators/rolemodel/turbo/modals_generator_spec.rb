RSpec.describe Rolemodel::Turbo::ModalsGenerator, type: :generator do
  before { run_generators(command_line_options, generators:) }
  let(:command_line_options) { [] }
  let(:generators) { [::Rolemodel::SlimGenerator, ::Rolemodel::WebpackGenerator, ::Rolemodel::Optics::BaseGenerator, described_class] }

  it 'adds the correct javascript files' do
    assert_file 'app/javascript/controllers/toggle_controller.js'
    assert_file 'app/javascript/initializers/frame_missing_handler.js'
  end

  it 'updates the stimulus manifest' do
    assert_file 'app/javascript/controllers/index.js' do |content|
      expect(content).to include('import ToggleController from "./toggle_controller"')
      expect(content).to include('application.register("toggle", ToggleController)')
    end
  end

  it 'imports initializers into application.js' do
    assert_file 'app/javascript/application.js' do |content|
      expect(content).to include("import './initializers/frame_missing_handler.js'")
    end
  end

  describe 'default options (--no-panels)' do
    it 'adds modal layout only' do
      assert_file 'app/views/layouts/modal.html.slim'
      assert_no_file 'app/views/layouts/panel.html.slim'
    end

    it 'updates application layout with modal turbo-frame only' do
      assert_file 'app/views/layouts/application.html.slim' do |content|
        expect(content).to match(/\s+= turbo_frame_tag 'modal'$/)
        expect(content).not_to match(/\s+= turbo_frame_tag 'panel'$/)
      end
    end
  end

  describe 'with --panels option' do
    let(:command_line_options) { ['--panels'] }

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
