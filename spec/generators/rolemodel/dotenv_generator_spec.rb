RSpec.describe Rolemodel::DotenvGenerator, type: :generator, env_value: false do
  it 'adds dotenv to the development and test groups' do
    run_generators

    assert_file 'Gemfile' do |content|
      expect(content).to match(/group :development, :test do\n(.*\n)*?\s+gem "dotenv"/)
    end
  end

  it 'ignores .env files' do
    run_generators

    assert_file '.gitignore' do |content|
      expect(content).to include('/.env*')
    end
  end

  it 'does not ignore .env files twice' do
    File.write(File.join(destination_root, '.gitignore'), "/.env*\n")

    run_generators

    assert_file '.gitignore' do |content|
      expect(content.scan('/.env*').size).to eq 1
    end
  end

  it 'adds EnvValue and requires it from config/application.rb' do
    run_generators

    assert_file 'lib/env_value.rb'
    assert_file 'config/application.rb' do |content|
      expect(content).to include("require_relative '../lib/env_value'\n# Require the gems listed in Gemfile")
    end
  end

  it 'warns about a leftover .env_overrides.rb once' do
    run_generators
    run_generators

    assert_file 'config/application.rb' do |content|
      expect(content.scan("File.expand_path('../.env_overrides.rb', __dir__)").size).to eq 1
      expect(content).to include("warn '.env_overrides.rb is no longer loaded.")
    end
  end

  it 'reads database settings from ENV in the default block once' do
    run_generators
    run_generators

    assert_file 'config/database.yml' do |content|
      expect(content).to include(<<~YML)
        default: &default
          adapter: postgresql
          host: <%= EnvValue.string('DB_HOST') { 'localhost' if EnvValue.string('POSTGRES_USER') } %>
          port: <%= EnvValue.string('DB_PORT') %>
          username: <%= EnvValue.string('POSTGRES_USER') %>
          password: <%= EnvValue.string('POSTGRES_PASSWORD') %>
          encoding: unicode
      YML
      expect(content.scan('DB_HOST').size).to eq 1
    end
  end

  it 'adds the EnvValue spec only when the app has a spec folder' do
    run_generators
    assert_no_file 'spec/lib/env_value_spec.rb'

    FileUtils.mkdir_p(File.join(destination_root, 'spec'))
    run_generators
    assert_file 'spec/lib/env_value_spec.rb'
  end
end
