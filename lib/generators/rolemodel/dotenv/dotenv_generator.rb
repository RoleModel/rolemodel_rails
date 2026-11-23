# frozen_string_literal: true

module Rolemodel
  class DotenvGenerator < GeneratorBase
    source_root File.expand_path('templates', __dir__)

    def install_dotenv
      say 'Installing dotenv', :green

      bundle_command('add dotenv --group "development, test"')
    end

    # New Rails apps already ignore /.env*. Older apps may not.
    def ignore_env_files
      gitignore = File.join(destination_root, '.gitignore')
      content = File.exist?(gitignore) ? File.read(gitignore) : ''
      return if content.include?('/.env*')

      create_file '.gitignore', content + <<~IGNORE, force: true

        # Ignore all environment files.
        /.env*
      IGNORE
    end

    def add_env_value
      say 'Adding EnvValue to read settings from ENV', :green

      copy_file 'lib/env_value.rb'
      inject_into_file(
        'config/application.rb',
        "require_relative '../lib/env_value'\n",
        before: /^# Require the gems listed in Gemfile/
      )
    end

    def add_env_value_spec
      return unless Dir.exist?(File.join(destination_root, 'spec'))

      copy_file 'spec/lib/env_value_spec.rb'
    end

    # .env_overrides.rb is ignored by Git, so it stays on a developer's machine after the app
    # moves to .env.local. Nothing loads it any more, so warn until it is gone.
    def warn_about_env_overrides
      return if File.read(File.join(destination_root, 'config/application.rb')).include?('.env_overrides.rb')

      inject_into_class 'config/application.rb', 'Application', optimize_indentation(<<~'RUBY', 4), at: :end
        if Rails.env.local? && File.exist?(File.expand_path('../.env_overrides.rb', __dir__))
          warn '.env_overrides.rb is no longer loaded. Move its values to .env.local as KEY=value lines, then delete it.'
        end
      RUBY
    end

    # A blank value renders as an empty YAML value, which is nil, so PostgreSQL uses its own
    # default: the local socket, port 5432 and the OS user. DATABASE_URL still wins over these.
    def read_database_settings_from_env
      database_yml = File.join(destination_root, 'config/database.yml')
      return if !File.exist?(database_yml) || File.read(database_yml).include?("EnvValue.string('DB_HOST')")

      inject_into_file 'config/database.yml', after: /^default: &default\n\s+adapter: .*\n/ do
        <<~'YML'.indent(2)
          host: <%= EnvValue.string('DB_HOST') %>
          port: <%= EnvValue.string('DB_PORT') %>
          username: <%= EnvValue.string('POSTGRES_USER') %>
          password: <%= EnvValue.string('POSTGRES_PASSWORD') %>
        YML
      end
    end
  end
end
