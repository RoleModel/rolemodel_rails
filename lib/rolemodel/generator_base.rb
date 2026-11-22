# frozen_string_literal: true

require 'rails/generators'
require 'rails/generators/bundle_helper'
require_relative 'file_content_helper'
require_relative 'skills_helper'
require 'rolemodel/yarn'

module Rolemodel
  class GeneratorBase < ::Rails::Generators::Base
    include ::Rails::Generators::BundleHelper, FileContentHelper, SkillsHelper

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

    # Adds a setting that reads ENV through EnvValue as the last line of `class Application`
    # in config/application.rb, for example
    # add_setting("config.x.sentry.dsn = EnvValue.string('SENTRY_DSN')").
    # Runs rolemodel:dotenv first when the app has no EnvValue yet.
    def add_setting(line)
      ensure_env_value
      inject_into_class 'config/application.rb', 'Application', optimize_indentation(line, 4), at: :end
    end

    # Sets every URL built outside a request, such as links and assets in emails, from DEFAULT_URL,
    # as Almanac does. Heroku apps with no DEFAULT_URL, such as review apps, use their herokuapp.com
    # address, and local apps use http://localhost:3000. Safe to call from several generators.
    def add_default_url
      # Rails splits a full URL given as host: into its protocol, host and port.
      add_setting <<~'RUBY'
        # Links in emails, and URLs built outside a request, use DEFAULT_URL.
        config.x.default_url = EnvValue.url('DEFAULT_URL') do
          heroku_app = EnvValue.string('HEROKU_APP_NAME')
          heroku_app ? "https://#{heroku_app}.herokuapp.com" : 'http://localhost:3000'
        end
        config.action_mailer.default_url_options = { host: config.x.default_url }
        config.action_mailer.asset_host = config.x.default_url
        Rails.application.routes.default_url_options = config.action_mailer.default_url_options
      RUBY

      # New Rails apps set their own default_url_options in development.rb and production.rb, and
      # those files run after application.rb, so they would win over DEFAULT_URL. Comment them out.
      # test.rb keeps its own, so tests still build URLs for example.com.
      %w[development production].each do |env|
        comment_lines "config/environments/#{env}.rb", /config\.action_mailer\.default_url_options\s*=/
      end
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
