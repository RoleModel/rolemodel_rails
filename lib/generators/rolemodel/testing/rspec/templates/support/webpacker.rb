RSpec.configure do |config|
  config.before(:all, type: :system) do
    # This runs once for each system spec file. There isn't a good way to run
    # this once for the whole suite without making it apply to non-system specs
    # (before(:suite) can't filter on metadata).
    #
    # Webpacker.compile checks if there are new changes to compile, so this does
    # not recompile on every call, but the check itself can be slow.
    Webpacker.compile
  end
end
