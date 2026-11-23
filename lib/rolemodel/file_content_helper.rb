require 'prism'

module Rolemodel
  module FileContentHelper
    # Finds a block for inject_into_block. `pattern` matches a Prism node by its structure, not its text.
    # `example` is code the pattern matches. Its first line describes the matcher in error messages,
    # and a spec checks that the pattern matches it. Build one with for_class, for_module or for_call.
    BlockMatcher = Data.define(:example, :pattern) do
      # A matcher for a class, by its name ('User', 'Admin::User'), its superclass
      # ('Rails::Application'), or both. A leading :: on either name does not matter.
      def self.for_class(name: nil, superclass: nil)
        parent = constant_argument(superclass)
        definition(Prism::ClassNode, 'class', name, suffix: (" < #{parent}" if parent)) do |node|
          parent.nil? || constant_name(node.superclass) == parent
        end
      end

      # A matcher for a module, by its name ('Admin', 'Admin::Reports'). A leading :: does not matter.
      def self.for_module(name)
        definition(Prism::ModuleNode, 'module', name)
      end

      # A matcher for a method call with a do ... end block, given as the names in its chain, such as
      # for_call(:Rails, :application, :configure). The first name may be a constant, such as :Rails or
      # 'Admin::Settings', with or without a leading ::. Without one, the chain must start with a call
      # that has no receiver, as in for_call(:configure). It does not compare arguments.
      def self.for_call(first, *rest)
        names = [constant_argument(first), *rest.map(&:to_s)]
        new(
          example: "#{names.join('.')} do\nend\n",
          pattern: lambda do |node|
            node.is_a?(Prism::CallNode) &&
              node.block.is_a?(Prism::BlockNode) &&
              same_chain?(node, names)
          end
        )
      end

      # A matcher for a class or module definition: a node of `type` whose name is `name`, when given,
      # and that passes the block, when given.
      def self.definition(type, keyword, name, suffix: nil, &extra)
        name = constant_argument(name)
        new(
          example: "#{keyword} #{name || 'Example'}#{suffix}\nend\n",
          pattern: lambda do |node|
            node.is_a?(type) &&
              (name.nil? || constant_name(node.constant_path) == name) &&
              (extra.nil? || extra.call(node))
          end
        )
      end

      # A constant name given to a factory, as a String without a leading ::, or nil when not given.
      def self.constant_argument(name)
        name&.to_s&.delete_prefix('::')
      end

      # A constant's full name without a leading ::, or nil when the node is not a plain constant,
      # such as `Struct.new(:x)` or `foo::Bar`.
      def self.constant_name(node)
        node.full_name.delete_prefix('::') if node.respond_to?(:full_name)
      rescue Prism::ConstantPathNode::DynamicPartsInConstantPathError
        nil
      end

      # Whether `node` and its receivers are the chain `names`, read from the end: each call's name
      # in turn, then either a constant with the first name or no receiver at all.
      def self.same_chain?(node, names)
        return node.nil? if names.empty?

        *rest, last = names
        if node.is_a?(Prism::CallNode)
          node.name.to_s == last && same_chain?(node.receiver, rest)
        else
          rest.empty? && constant_name(node) == last
        end
      end
      private_class_method :definition, :constant_argument, :constant_name, :same_chain?

      def call(node) = pattern.call(node)
      def to_s = example.lines.first.strip

      # The first node in `source` that the pattern matches, or nil.
      def find_in(source) = Prism.parse(source).value.breadth_first_search { call(it) }
    end

    private

    def replace_content(relative_path)
      source = File.expand_path(relative_path.to_s, destination_root)
      content = File.exist?(source) ? File.open(source) { it.binmode.read } : ''

      remove_file relative_path
      create_file relative_path, yield(content)
    end

    def modify_json_file(relative_path)
      replace_content(relative_path) do |content|
        # Editor config files such as .vscode/*.json allow comments and trailing commas.
        # Writing the file back drops the comments.
        hash = JSON.parse(
          content.presence || '{}',
          allow_comments: true,
          allow_trailing_comma: true
        )
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

    # Adds code as the last lines of the `Rails.application.configure` block in an environment file,
    # indented 2 spaces, so it overrides the Rails defaults above it.
    # Rails' own `environment(code, env:)` adds it at the top instead.
    def append_to_environment(env, code)
      inject_into_block(
        "config/environments/#{env}.rb",
        BlockMatcher.for_call(:Rails, :application, :configure),
        optimize_indentation(code, 2),
        at: :end
      )
    end

    # Overrides Thor's inject_into_class, with the same arguments and options. See inject_into_block.
    def inject_into_class(path, klass, *args, &block)
      inject_into_block(path, BlockMatcher.for_class(name: klass), *args, &block)
    end

    # Overrides Thor's inject_into_module, with the same arguments and options. See inject_into_block.
    def inject_into_module(path, module_name, *args, &block)
      inject_into_block(path, BlockMatcher.for_module(module_name), *args, &block)
    end

    # Adds data inside the first block in a file that `matcher`, a BlockMatcher, accepts. A block is any
    # code that closes with `end`: a class, module, method, or a do ... end block.
    #
    # Works like Thor's inject_into_class: data as a string or a block, the :verbose and :force options,
    # and no change to the data's indentation. It adds one option: at: :start (the default) adds the data
    # right after the block's opening line, and at: :end adds it just before the block's `end`.
    #
    # Prism finds the block, so spacing, comments and code around it do not change where the data goes,
    # and it raises when the block is missing, where Thor prints "unchanged" and goes on. Thor's
    # insert_into_file still writes the data, so it skips data the file already has, honors --pretend,
    # and `rails destroy` can remove it.
    def inject_into_block(path, matcher, *args, &block)
      config = args.extract_options!
      at = config.delete(:at) || :start
      unless %i[start end].include?(at)
        raise ArgumentError, "at: must be :start or :end, not #{at.inspect}"
      end

      content = File.read(File.join(destination_root, path))
      opening_line, closing = block_lines(matcher.find_in(content))
      unless closing
        raise Thor::Error, "Could not find `#{matcher}` with `end` on its own line in #{path}"
      end

      lines_before = content.lines.first(at == :start ? opening_line : closing.start_line - 1).join
      config[:after] = /\A#{Regexp.escape(lines_before)}/
      insert_into_file(path, *(args << config), &block)
    end

    # For a block, the last line of its opening (such as `class User < ApplicationRecord`, or
    # `configure do |config|` when the opening wraps), and the location of the `end` that closes it.
    # Returns nil unless the `end` keyword starts its own line. A `{ }` block has no `end`.
    def block_lines(node)
      opening, closing = case node
                         in Prism::ClassNode
                           [node.superclass || node.constant_path, node.end_keyword_loc]
                         in Prism::ModuleNode
                           [node.constant_path, node.end_keyword_loc]
                         in Prism::DefNode
                           [node.rparen_loc || node.name_loc, node.end_keyword_loc]
                         in Prism::CallNode[block: Prism::BlockNode => block]
                           [block.parameters || block.opening_loc, block.closing_loc]
                         else return
                         end
      return unless closing.slice == 'end' && closing.start_line_slice.strip.empty?

      opening = opening.location if opening.respond_to?(:location)
      [opening.end_line, closing]
    end
  end
end
