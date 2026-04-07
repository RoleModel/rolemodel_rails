require "rails/generators/rails/app/app_generator"

Rails::Generators::AppGenerator.define_method(:rails_version_specifier) do
  "~> #{RAILS_VERSION}"
end

class BuilderClass < Rails::AppBuilder
  # inherit these from Rolemodel::Rails
  def ruby_version = nil
  def node_version = nil

  def generate_test_dummy
    invoke Rails::Generators::AppGenerator, [ File.expand_path(app_path) ], {
      dummy_app: true,
      force: true,
      database: 'postgresql',
      javascript: 'webpack',
      skip_bootsnap: true,
      skip_brakeman: true,
      skip_bundler_audit: true,
      skip_ci: true,
      skip_git: true,
      skip_jbuilder: true,
      skip_kamal: true,
      skip_rubocop: true,
      skip_solid: true,
      skip_test: true,
      skip_thruster: true,
    }
  end

  def test_dummy_config
    directory 'config', "#{app_path}/config", force: true
  end
end
