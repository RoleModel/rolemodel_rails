require 'thor'
require 'thor/actions'

module Rolemodel
  class Yarn < ::Thor
    include ::Thor::Actions

    # Enable Corepack and pin the project to Yarn 4+ (instead of the classic
    # Yarn 1.22). Idempotent, so any generator can call it before running a
    # `yarn` command to guarantee the modern toolchain is in place.
    desc 'setup', 'Set the current stable version of Yarn, enable corepack, and initialize a package.json file'
    def setup
      # Configure the node-modules linker so webpack, Playwright, and the Rails
      # asset pipeline keep working (Yarn 4 defaults to Plug'n'Play otherwise).
      # skip if exists? to avoid overwriting any other existing config
      create_file '.yarnrc.yml', "nodeLinker: node-modules\n", skip: true

      yes! 'yarn set version stable'
      yes! 'corepack enable'
      yes! 'yarn init'

      ignore_yarn_install_state
    end

    private

    def ignore_yarn_install_state
      gitignore = File.expand_path('.gitignore', destination_root)
      return create_file '.gitignore', "/.yarn/install-state.gz\n" unless File.exist?(gitignore)
      return if File.read(gitignore).include?('/.yarn/install-state.gz')

      append_to_file '.gitignore', "\n/.yarn/install-state.gz\n"
    end

    def yes!(command)
      Open3.popen3(command) do |stdin, stdout, stderr, wait_thr|
        stdin.puts 'y'
        stdin.close
      end
    end
  end
end
