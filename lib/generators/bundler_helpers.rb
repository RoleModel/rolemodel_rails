module BundlerHelpers
  private

  # taken from https://github.com/rails/rails/blob/2fe20cb55c76e6e50ec3a4ec5b03bbb65adba290/railties/lib/rails/generators/app_base.rb#L406
  def run_bundle
    bundle_command("install", "BUNDLE_IGNORE_MESSAGES" => "1")
  end

  # taken from https://github.com/rails/rails/blob/2fe20cb55c76e6e50ec3a4ec5b03bbb65adba290/railties/lib/rails/generators/app_base.rb#L352
  def bundle_command(command, env = {})
    say_status :run, "bundle #{command}"

    # We are going to shell out rather than invoking Bundler::CLI.new(command)
    # because `rails new` loads the Thor gem and on the other hand bundler uses
    # its own vendored Thor, which could be a different version. Running both
    # things in the same process is a recipe for a night with paracetamol.
    #
    # Thanks to James Tucker for the Gem tricks involved in this call.
    _bundle_command = Gem.bin_path("bundler", "bundle")

    require "bundler"
    Bundler.with_original_env do
      exec_bundle_command(_bundle_command, command, env)
    end
  end

  def exec_bundle_command(bundle_command, command, env)
    full_command = %Q["#{Gem.ruby}" "#{bundle_command}" #{command}]
    if options[:quiet]
      system(env, full_command, out: File::NULL)
    else
      system(env, full_command)
    end
  end
end
