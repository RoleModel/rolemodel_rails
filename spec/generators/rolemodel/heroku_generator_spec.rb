require 'spec_helper'
require 'generators/rolemodel/heroku/heroku_generator'

RSpec.describe Rolemodel::HerokuGenerator, type: :generator do
  destination File.expand_path('tmp/', File.dirname(__FILE__))

  before { run_generator_against_test_app }

  it 'generates app.json' do
    assert_file 'app.json' do |content|
      expect(content).to include('"name": ""') # erb replacement is happening, though application name is nil
    end
  end

  it 'generates Procfile' do
    assert_file 'Procfile'
  end

  it 'forces SSL in production environment' do
    assert_file 'config/environments/production.rb' do |content|
      expect(content).not_to include('# config.force_ssl = true')
      expect(content).to include('config.force_ssl = true')
    end
  end

  it 'enables log-level adjustment via "LOG_LEVEL" environment variable' do
    assert_file 'config/environments/production.rb' do |content|
      expect(content).to include("config.log_level = ENV.fetch('LOG_LEVEL', 'INFO')")
    end
  end

  it 'creates assets.rake task to remove node_modules directory during production build' do
    assert_file 'lib/tasks/assets.rake'
  end
end
