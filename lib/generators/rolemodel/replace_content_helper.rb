module Rolemodel
  module ReplaceContentHelper
    private

    def replace_content(relative_path, &block)
      source = File.expand_path(relative_path.to_s, destination_root)
      content = File.exist?(source) ? File.open(source) { it.binmode.read } : ''

      remove_file relative_path
      create_file relative_path, yield(content)
    end

    def modify_json_file(relative_path, &block)
      replace_content(relative_path) do |content|
        hash = JSON.parse(content.presence || '{}')
        yield(hash)
        JSON.pretty_generate(hash) + "\n"
      end
    end

    def add_package_json_script(command_name, command)
      modify_json_file('package.json') do |hash|
        hash['scripts'] ||= {}
        hash['scripts'][command_name] = command
        hash
      end
    end
  end
end
