require 'pathname'

module Rolemodel
  RUBY_VERSION = Pathname.pwd.join('.ruby-version').read.strip
  NODE_VERSION = Pathname.pwd.join('.node-version').read.strip

  autoload :BundlerHelpers, File.expand_path('./bundler_helpers', __dir__)
  autoload :ReplaceContentHelper, File.expand_path('./replace_content_helper', __dir__)
end
