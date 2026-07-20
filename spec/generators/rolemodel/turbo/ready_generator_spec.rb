RSpec.describe Rolemodel::Turbo::ReadyGenerator, type: :generator do
  destination File.expand_path('../../tmp/', File.dirname(__FILE__))

  before { run_generators_against_test_app(generators:) }
  let(:generators) { [::Rolemodel::SlimGenerator, ::Rolemodel::WebpackGenerator, described_class] }

  it 'adds the correct javascript files' do
    assert_file 'app/javascript/controllers/prevent_morph_controller.js'
    assert_file 'app/javascript/initializers/before_morph_handler.js'
  end

  it 'updates the stimulus manifest' do
    assert_file 'app/javascript/controllers/index.js' do |content|
      expect(content).to include('import PreventMorphController from "./prevent_morph_controller"')
      expect(content).to include('application.register("prevent-morph", PreventMorphController)')
    end
  end

  it 'imports initializers into application.js' do
    assert_file 'app/javascript/application.js' do |content|
      expect(content).to include("import './initializers/before_morph_handler.js'")
    end
  end

  it 'adds a head outlet to the head partial' do
    assert_file 'app/views/application/_head.html.slim' do |content|
      expect(content).to include('meta name="turbo-refresh-method" content="morph"')
      expect(content).to include('meta name="turbo-refresh-scroll" content="preserve"')
      expect(content).to include('= yield :head')
    end
  end
end
