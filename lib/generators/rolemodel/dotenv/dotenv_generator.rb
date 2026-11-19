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
      inject_into_file 'config/application.rb', "require_relative '../lib/env_value'\n",
                       before: /^# Require the gems listed in Gemfile/
    end

    def add_env_value_spec
      return unless Dir.exist?(File.join(destination_root, 'spec'))

      copy_file 'spec/lib/env_value_spec.rb'
    end
  end
end
