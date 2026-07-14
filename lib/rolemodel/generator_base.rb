# frozen_string_literal: true

require 'rails/generators'
require 'rails/generators/bundle_helper'
require_relative 'replace_content_helper'

module Rolemodel
  class GeneratorBase < ::Rails::Generators::Base
    include ::Rails::Generators::BundleHelper, ReplaceContentHelper

    private
    # based on https://github.com/rails/rails/blob/main/railties/lib/rails/generators/app_base.rb#L713
    def run_bundle
      bundle_command("install --quiet", "BUNDLE_IGNORE_MESSAGES" => "1")
    end

    # Enable Corepack and pin the project to Yarn 4+ (instead of the classic
    # Yarn 1.22). Idempotent, so any generator can call it before running a
    # `yarn` command to guarantee the modern toolchain is in place.
    def ensure_yarn
      return if @yarn_ensured

      run 'corepack enable'

      unless File.exist?(File.expand_path('package.json', destination_root))
        create_file 'package.json', JSON.pretty_generate({}) + "\n"
      end

      # Configure the node-modules linker so webpack, Playwright, and the Rails
      # asset pipeline keep working (Yarn 4 defaults to Plug'n'Play otherwise).
      create_file '.yarnrc.yml', "nodeLinker: node-modules\n", force: true

      pin_yarn_version
      ignore_yarn_install_state

      @yarn_ensured = true
    end

    def pin_yarn_version
      modify_json_file('package.json') do |hash|
        hash['packageManager'] = "yarn@#{YARN_VERSION}"
        hash
      end
    end

    def ignore_yarn_install_state
      gitignore = File.expand_path('.gitignore', destination_root)
      return create_file '.gitignore', "/.yarn/install-state.gz\n" unless File.exist?(gitignore)
      return if File.read(gitignore).include?('/.yarn/install-state.gz')

      append_to_file '.gitignore', "\n/.yarn/install-state.gz\n"
    end
  end
end
