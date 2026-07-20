RSpec.describe Rolemodel::Turbo::ReadyGenerator, type: :generator do
  destination File.expand_path('../../tmp/', File.dirname(__FILE__))

  before do
    run_generator_against_test_app(generator: ::Rolemodel::SlimGenerator)
    run_generator_against_test_app(generator: ::Rolemodel::WebpackGenerator)
    run_generator_against_test_app(generator: ::Rolemodel::Optics::BaseGenerator)
    run_generator_against_test_app(command_line_options)
  end

  let(:command_line_options) { [] }

  it 'adds the correct javascript files' do
    assert_file 'app/javascript/controllers/prevent_morph_controller.js'
    assert_file 'app/javascript/initializers/before_morph_handler.js'
  end

  it 'updates the stimulus manifest' do
    assert_file 'app/javascript/controllers/index.js' do |content|
      expect(content).to match(/import PreventMorphController from "\.\/prevent_morph_controller"/)
      expect(content).to match(/application\.register\("prevent-morph", PreventMorphController\)/)
    end
  end

  it 'imports initializers into application.js' do
    assert_file 'app/javascript/application.js' do |content|
      expect(content).to include("import './initializers/before_morph_handler.js'")
    end
  end
end
