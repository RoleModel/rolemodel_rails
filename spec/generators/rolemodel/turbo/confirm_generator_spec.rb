RSpec.describe Rolemodel::Turbo::ConfirmGenerator, type: :generator do
  destination File.expand_path('../../tmp/', File.dirname(__FILE__))

  before { run_generators(generators:) }
  let(:generators) { [::Rolemodel::SlimGenerator, ::Rolemodel::WebpackGenerator, described_class] }

  it 'adds the turbo-confirm package to package.json' do
    assert_file 'package.json' do |content|
      expect(content).to include('"@rolemodel/turbo-confirm"')
    end
  end

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
