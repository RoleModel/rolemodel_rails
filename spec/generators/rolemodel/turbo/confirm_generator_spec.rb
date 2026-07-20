RSpec.describe Rolemodel::Turbo::ConfirmGenerator, type: :generator do
  destination File.expand_path('../../tmp/', File.dirname(__FILE__))

  before do
    run_generator_against_test_app(generator: ::Rolemodel::SlimGenerator)
    run_generator_against_test_app(generator: ::Rolemodel::WebpackGenerator)
    run_generator_against_test_app(generator: ::Rolemodel::Optics::BaseGenerator)
    run_generator_against_test_app(command_line_options)
  end

  let(:command_line_options) { [] }

  it 'adds the correct javascript files' do
    assert_file 'app/javascript/initializers/turbo_confirm.js'
  end

  it 'imports initializers into application.js' do
    assert_file 'app/javascript/application.js' do |content|
      expect(content).to include("import './initializers/turbo_confirm.js'")
    end
  end

  it 'adds confirmation partials' do
    assert_file 'app/views/application/_confirm.html.slim'

    assert_file 'app/views/layouts/application.html.slim' do |content|
      expect(content).to match(/\s+= render 'confirm'$/)
    end
  end
end
