RSpec.describe Rolemodel::SlimGenerator, type: :generator do
  before { run_generator_against_test_app }

  it 'replaces erb layout' do
    assert_no_file 'app/views/layouts/application.html.erb'
    assert_file 'app/views/layouts/application.html.slim' do |content|
      expect(content).to match(/\s+head = render 'head'$/)
    end
  end

  it 'adds slim and slim-rails gems' do
    assert_file 'Gemfile' do |content|
      expect(content).to include('gem "slim"')
      expect(content).to include('gem "slim-rails"')
    end
  end

  it 'copies head partial' do
    assert_file 'app/views/application/_head.html.slim' do |content|
      expect(content).to include("= yield :head")
    end
  end

  it 'generates scaffolding templates' do
    %w[edit index new partial show].each do |template|
      assert_file "lib/templates/slim/scaffold/#{template}.html.slim" do |content|
        expect(content).to include("<%=")
        expect(content).not_to include("<%%=")
      end
    end
  end
end
