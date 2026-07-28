# frozen_string_literal: true

require 'rails/generators'
require 'rails/generators/bundle_helper'
require_relative 'replace_content_helper'
require 'rolemodel/yarn'

module Rolemodel
  class GeneratorBase < ::Rails::Generators::Base
    include ::Rails::Generators::BundleHelper, ReplaceContentHelper

    private
    # based on https://github.com/rails/rails/blob/main/railties/lib/rails/generators/app_base.rb#L713
    def run_bundle
      bundle_command("install --quiet", "BUNDLE_IGNORE_MESSAGES" => "1")
    end

    def yarn_command(command)
      ensure_yarn

      run "yarn #{command}"
    end

    # Enable Corepack and pin the project to Yarn 4+ before running any `yarn`
    # command. Empty args/opts are required: without them, Thor forwards this
    # generator's own CLI args (e.g. the test harness's --skip-bundle
    # --skip-bootsnap) into Rolemodel::Yarn#setup, which takes none and raises
    # Thor::InvocationError.
    def ensure_yarn
      return if Rails.root.join(destination_root, '.yarnrc.yml').exist?
      invoke 'rolemodel:yarn:setup', [], {}
    end

    def application_stylesheet_path
      Dir.glob('app/assets/stylesheets/application.*').first
    end
  end
end
