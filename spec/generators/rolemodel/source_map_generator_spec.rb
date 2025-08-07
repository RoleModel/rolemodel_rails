require 'spec_helper'
require 'generators/rolemodel/source_map/source_map_generator'

RSpec.describe Rolemodel::SourceMapGenerator, type: :generator do
  destination File.expand_path('tmp/', File.dirname(__FILE__))

  before { run_generator_against_test_app }

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
end
