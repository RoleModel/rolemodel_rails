module Rolemodel
  module ReplaceContentHelper
    private

    def replace_content(relative_path, &block)
      source = File.expand_path(relative_path.to_s, destination_root)
      content = File.open(source) { it.binmode.read }

      remove_file relative_path
      create_file relative_path, yield(content)
    end
  end
end
