# frozen_string_literal: true

require 'rails/generators'
require 'rails/generators/bundle_helper'
require_relative 'replace_content_helper'
require_relative 'skills_helper'
require 'rolemodel/yarn'

module Rolemodel
  class GeneratorBase < ::Rails::Generators::Base
    include ::Rails::Generators::BundleHelper, ReplaceContentHelper, SkillsHelper

    private

    # Thor's ask loops forever on EOF when limited_to is set, so only prompt when someone can answer.
    def ask_or_default(statement, default:, **)
      $stdin.tty? ? ask(statement, default:, **) : default
    end

    # based on https://github.com/rails/rails/blob/main/railties/lib/rails/generators/app_base.rb#L713
    def run_bundle
      bundle_command("install --quiet", "BUNDLE_IGNORE_MESSAGES" => "1")
    end

    def yarn_command(command)
      ensure_yarn

      run "yarn #{command}"
    end

    # Enable Corepack and pin the project to Yarn 4+ before running any `yarn`
    # command. Args/opts are passed explicitly: otherwise Thor forwards this
    # generator's own CLI args (e.g. the test harness's --skip-bundle
    # --skip-bootsnap) into Rolemodel::Yarn#setup, which takes none and raises
    # Thor::InvocationError.
    def ensure_yarn
      return if Rails.root.join(destination_root, '.yarnrc.yml').exist?
      invoke 'rolemodel:yarn:setup', [], options.slice(:pretend)
    end

    # Adds a setting to config/application.rb that reads ENV through EnvValue,
    # for example add_setting("config.x.sentry.dsn = EnvValue.string('SENTRY_DSN')").
    # Runs rolemodel:dotenv first when the app has no EnvValue yet. Skips a setting the file already has.
    def add_setting(line)
      ensure_env_value
      return if File.read(File.join(destination_root, 'config/application.rb')).include?(line)

      inject_into_file 'config/application.rb', "    #{line}\n", before: /^  end\nend/
    end

    def ensure_env_value
      return if File.exist?(File.join(destination_root, 'lib/env_value.rb'))

      invoke 'rolemodel:dotenv', [], options.slice(:pretend)
    end

    def application_stylesheet_path
      Dir.glob('app/assets/stylesheets/application.*').first
    end
  end
end
