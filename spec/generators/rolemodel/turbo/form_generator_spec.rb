RSpec.describe Rolemodel::Turbo::FormGenerator, type: :generator do
  destination File.expand_path('../../tmp/', File.dirname(__FILE__))

  before { run_generators_against_test_app(generators:) }
  let(:generators) { [::Rolemodel::SlimGenerator, ::Rolemodel::WebpackGenerator, described_class] }

  it 'adds the turbo-confirm package to package.json' do
    assert_file 'package.json' do |content|
      expect(content).to include('"@rails/request.js"')
    end
  end

  it 'adds the stimulus controller' do
    assert_file 'app/javascript/controllers/turbo_form_controller.js'
  end

  it 'updates the stimulus manifest' do
    assert_file 'app/javascript/controllers/index.js' do |content|
      expect(content).to include('import TurboFormController from "./turbo_form_controller"')
      expect(content).to include('application.register("turbo-form", TurboFormController)')
    end
  end
end
