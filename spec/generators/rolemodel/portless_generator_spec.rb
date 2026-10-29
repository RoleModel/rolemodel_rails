RSpec.describe Rolemodel::PortlessGenerator, type: :generator do
  before { run_generators }

  it 'adds an executable bin/portless' do
    assert_file 'bin/portless'
    expect(File.executable?(File.join(destination_root, 'bin/portless'))).to be true
  end

  it 'runs the web process through portless under the app name' do
    assert_file 'Procfile.pdev' do |content|
      expect(content).to include('web: env RUBY_DEBUG_OPEN=true portless example-rails-current bin/rails server')
      expect(content).to include('js: yarn build --watch')
    end
  end
end
