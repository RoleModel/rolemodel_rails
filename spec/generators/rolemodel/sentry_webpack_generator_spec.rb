# frozen_string_literal: true

RSpec.describe Rolemodel::SentryWebpackGenerator, type: :generator do
  it 'wires the Sentry plugin into the webpack.config.js' do
    # The webpack generator lays down the modern config with the anchors this
    # hook injects into.
    run_generator_against_test_app generator: ::Rolemodel::WebpackGenerator
    run_generator_against_test_app

    assert_file 'webpack.config.js' do |content|
      expect(content).to include("import { sentryWebpackPlugin } from '@sentry/webpack-plugin'")
      expect(content).to include("'process.env.SENTRY_DSN': JSON.stringify(process.env.SENTRY_DSN),")
      expect(content).to include('sentryWebpackPlugin({')
      expect(content).to include('].filter(Boolean)')
    end
  end

  it 'is a no-op when there is no webpack.config.js' do
    File.delete(File.expand_path('webpack.config.js', destination_root))

    run_generator_against_test_app

    assert_no_file 'webpack.config.js'
  end

  it 'is idempotent when the plugin is already wired' do
    run_generator_against_test_app generator: ::Rolemodel::WebpackGenerator
    run_generator_against_test_app
    first_pass = File.read(File.expand_path('webpack.config.js', destination_root))

    run_generator_against_test_app

    expect(File.read(File.expand_path('webpack.config.js', destination_root))).to eq first_pass
  end

  it 'records no registry entry (it is a wiring-only hook)' do
    run_generator_against_test_app

    assert_no_file 'config/initializers/rolemodel_generators.rb'
  end
end
