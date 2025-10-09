module Rolemodel
  NODE_VERSION = '22.15.0'

  autoload :BundlerHelpers, File.expand_path('./bundler_helpers', __dir__)
  autoload :ReplaceContentHelper, File.expand_path('./replace_content_helper', __dir__)
end
