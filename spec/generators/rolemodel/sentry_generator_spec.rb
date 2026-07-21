RSpec.describe Rolemodel::SentryGenerator, type: :generator do
  before do
    # The webpack generator lays down the webpack.config.js and application.js
    # that this generator injects into.
    run_generators generators: [::Rolemodel::WebpackGenerator, described_class]
  end

  it 'sets up the Ruby side' do
    assert_file 'config/initializers/sentry.rb' do |content|
      expect(content).to include('Sentry.init')
    end

    assert_file 'Gemfile' do |content|
      expect(content).to include('sentry-rails')
    end

    assert_file 'app/controllers/application_controller.rb' do |content|
      expect(content).to include('before_action :set_sentry_user')
      expect(content).to include('respond_to?(:current_user) && current_user')
      expect(content).to include('Sentry.set_user(id: current_user.id)')
    end
  end

  it 'sets up the JS side' do
    assert_file 'app/javascript/initializers/sentry.js' do |content|
      expect(content).to include("import * as Sentry from '@sentry/browser'")
    end

    assert_file 'app/javascript/application.js' do |content|
      expect(content).to include("import './initializers/sentry'")
    end

    assert_file 'package.json' do |content|
      dependencies = JSON.parse(content)['devDependencies'].keys
      expect(dependencies).to include(*Rolemodel::SentryGenerator::JS_DEPS)
    end
  end

  it 'wires the Sentry plugin into webpack.config.js' do
    assert_file 'webpack.config.js' do |content|
      expect(content).to include("import { sentryWebpackPlugin } from '@sentry/webpack-plugin'")
      expect(content).to include("'process.env.SENTRY_DSN': JSON.stringify(process.env.SENTRY_DSN),")
      expect(content).to include('sentryWebpackPlugin({')
      expect(content).to include('].filter(Boolean)')
    end
  end
end
