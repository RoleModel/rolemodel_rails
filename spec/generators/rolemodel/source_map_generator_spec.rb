RSpec.describe Rolemodel::SourceMapGenerator, type: :generator do
  before { run_generators }

  it 'enhances assets rake tasks to manage sourcemaps' do
    assert_file 'lib/tasks/assets.rake'
  end

  it 'adds a middleware to control access to sourcemaps' do
    assert_file 'lib/middleware/rolemodel/source_map.rb'
    assert_file 'config/environments/production.rb' do |content|
      expect(content).to include("require_relative Rails.root.join('lib/middleware/rolemodel/source_map.rb')")
      expect(content).to include('config.middleware.insert_after Warden::Manager, Middleware::Rolemodel::SourceMap')
    end
  end

  it 'reads the allowed emails from SOURCE_MAPS_ALLOWED_USERS_EMAILS' do
    assert_file 'config/application.rb' do |content|
      expect(content).to include("config.x.source_maps.allowed_user_emails = EnvValue.array('SOURCE_MAPS_ALLOWED_USERS_EMAILS')")
    end
    assert_file 'lib/middleware/rolemodel/source_map.rb' do |content|
      expect(content).to include('Rails.configuration.x.source_maps.allowed_user_emails')
    end
  end
end
