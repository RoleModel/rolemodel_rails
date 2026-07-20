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
      # Configure the node-modules linker so webpack, Playwright, and the Rails
      # asset pipeline keep working (Yarn 4 defaults to Plug'n'Play otherwise).
      # skip if exists? to avoid overwriting any other existing config
      create_file '.yarnrc.yml', "nodeLinker: node-modules\n", skip: true

      run 'yarn set version stable'
      yes! 'corepack enable'
      run 'yarn init'

      ignore_yarn_install_state

      @yarn_ensured = true
    end

    def ignore_yarn_install_state
      gitignore = File.expand_path('.gitignore', destination_root)
      return create_file '.gitignore', "/.yarn/install-state.gz\n" unless File.exist?(gitignore)
      return if File.read(gitignore).include?('/.yarn/install-state.gz')

      append_to_file '.gitignore', "\n/.yarn/install-state.gz\n"
    end

    def application_stylesheet_path
      Dir.glob('app/assets/stylesheets/application.*').first
    end

    def yes!(command)
      Open3.popen3(command) do |stdin, stdout, stderr, wait_thr|
        stdin.puts 'y'
        stdin.close
      end
    end
  end
end
