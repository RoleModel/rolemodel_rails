# frozen_string_literal: true

require 'rails/generators'
require 'rails/generators/bundle_helper'
require_relative 'replace_content_helper'
require 'rolemodel/yarn'
require 'json'
require 'open-uri'

module Rolemodel
  class GeneratorBase < ::Rails::Generators::Base
    include ::Rails::Generators::BundleHelper, ReplaceContentHelper

    SKILLS_REPO = 'RoleModel/rolemodel-skills'

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

    def install_skill(name, ref: 'main', into: '.claude/skills')
      files = skill_files(name, ref)
      return say_status(:missing, "#{SKILLS_REPO} skill '#{name}'", :red) if files.empty?

      files.each do |path|
        get "https://raw.githubusercontent.com/#{SKILLS_REPO}/#{ref}/#{path}",
            File.join(into, path.delete_prefix('skills/'))
      end
    end

    def skill_files(name, ref)
      tree = JSON.parse(URI.open("https://api.github.com/repos/#{SKILLS_REPO}/git/trees/#{ref}?recursive=1").read)
      tree['tree'].filter_map { it['path'] if it['type'] == 'blob' && it['path'].start_with?("skills/#{name}/") }
    end

    def application_stylesheet_path
      Dir.glob('app/assets/stylesheets/application.*').first
    end
  end
end
