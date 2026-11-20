require 'prism'

module Rolemodel
  module FileContentHelper
    # Finds a block for append_to_block. `pattern` matches a Prism node by its structure, not its text.
    # `example` is code the pattern matches. Its first line describes the matcher in error messages,
    # and a spec checks that the pattern matches it.
    BlockMatcher = Data.define(:example, :pattern) do
      def call(node) = pattern.call(node)
      def to_s = example.lines.first.strip

      # The first node in `source` that the pattern matches, or nil.
      def find_in(source) = Prism.parse(source).value.breadth_first_search { call(it) }
    end

    # Matches with or without a leading ::.
    RAILS_APPLICATION_CLASS = BlockMatcher.new(
      example: "class Application < Rails::Application\nend\n",
      pattern: lambda do |node|
        node in Prism::ClassNode[
          superclass: Prism::ConstantPathNode[
            name: :Application,
            parent: Prism::ConstantReadNode[name: :Rails] | Prism::ConstantPathNode[parent: nil, name: :Rails]
          ]
        ]
      end
    )

    RAILS_CONFIGURE_BLOCK = BlockMatcher.new(
      example: "Rails.application.configure do\nend\n",
      pattern: lambda do |node|
        node in Prism::CallNode[
          name: :configure,
          block: Prism::BlockNode,
          receiver: Prism::CallNode[name: :application, receiver: Prism::ConstantReadNode[name: :Rails]]
        ]
      end
    )

    private

    def replace_content(relative_path)
      source = File.expand_path(relative_path.to_s, destination_root)
      content = File.exist?(source) ? File.open(source) { it.binmode.read } : ''

      remove_file relative_path
      create_file relative_path, yield(content)
    end

    def modify_json_file(relative_path)
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

    # Adds code as the last lines of the `class ... < Rails::Application` body in config/application.rb.
    def append_to_application(code)
      append_to_block('config/application.rb', code, RAILS_APPLICATION_CLASS)
    end

    # Adds code as the last lines of the `Rails.application.configure` block in an environment file,
    # so it overrides the Rails defaults above it. Rails' own `environment(code, env:)` adds it at the top.
    def append_to_environment(env, code)
      append_to_block("config/environments/#{env}.rb", code, RAILS_CONFIGURE_BLOCK)
    end

    # Adds code as the last lines of the first block in a file that `matcher`, a BlockMatcher, accepts.
    # A block is any code that closes with `end`: a class, module, method, or a do ... end block.
    # Prism finds the closing `end`, so spacing, comments and code after it do not change where
    # the code goes. The code is indented one level deeper than that `end`.
    # Thor's inject_into_file writes it, so it skips code the file already has, honors --pretend,
    # and `rails destroy` can remove it.
    def append_to_block(relative_path, code, matcher)
      content = File.read(File.join(destination_root, relative_path))
      closing = closing_end(matcher.find_in(content))
      raise Thor::Error, "Could not find `#{matcher}` with `end` on its own line in #{relative_path}" unless closing

      lines_before_end = content.lines.first(closing.start_line - 1).join
      inject_into_file relative_path, optimize_indentation(code, closing.start_line_slice.length + 2),
                       after: /\A#{Regexp.escape(lines_before_end)}/
    end

    # The location of the `end` keyword that closes a node, when only spaces come before it on its line.
    # Returns nil otherwise. A `{ }` block has no `end`.
    def closing_end(node)
      closing = case node
                in Prism::ClassNode | Prism::ModuleNode | Prism::DefNode then node.end_keyword_loc
                in Prism::CallNode[block: Prism::BlockNode => block] then block.closing_loc
                else return
                end
      closing if closing.slice == 'end' && closing.start_line_slice.strip.empty?
    end
  end
end
