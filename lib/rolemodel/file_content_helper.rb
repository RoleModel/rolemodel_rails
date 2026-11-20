require 'prism'

module Rolemodel
  module FileContentHelper
    # Finds a block for inject_into_block. `pattern` matches a Prism node by its structure, not its text.
    # `example` is code the pattern matches. Its first line describes the matcher in error messages,
    # and a spec checks that the pattern matches it.
    BlockMatcher = Data.define(:example, :pattern) do
      def call(node) = pattern.call(node)
      def to_s = example.lines.first.strip

      # The first node in `source` that the pattern matches, or nil.
      def find_in(source) = Prism.parse(source).value.breadth_first_search { call(it) }
    end

    # A BlockMatcher for a class, by its name as written ('User', 'Admin::User'), its superclass
    # ('Rails::Application', with or without a leading ::), or both.
    def self.class_matcher(name: nil, superclass: nil)
      parent = superclass.to_s.delete_prefix('::').presence
      BlockMatcher.new(
        example: "class #{name || 'Example'}#{" < #{parent}" if parent}\nend\n",
        pattern: lambda do |node|
          node.is_a?(Prism::ClassNode) &&
            (name.nil? || node.constant_path.slice == name.to_s) &&
            (parent.nil? || constant_name(node.superclass) == parent)
        end
      )
    end

    # A constant's full name without a leading ::, or nil when the node is not a plain constant,
    # such as `Struct.new(:x)` or `foo::Bar`.
    def self.constant_name(node)
      node.full_name.delete_prefix('::') if node.respond_to?(:full_name)
    rescue Prism::ConstantPathNode::DynamicPartsInConstantPathError
      nil
    end

    # A BlockMatcher for a method call with a do ... end block, given as Ruby code such as
    # 'Rails.application.configure'. Prism parses the code, and the matcher compares the structure:
    # each method name and constant in the chain must be the same. It does not compare arguments,
    # and a leading :: on a constant does not matter.
    def self.call_matcher(source)
      expected = Prism.parse(source).value.statements.body
      expected = expected.first if expected.size == 1
      unless expected.is_a?(Prism::CallNode) && expected.block.nil?
        raise(
          ArgumentError,
          "#{source.inspect} must be one method call with no block, such as 'Rails.application.configure'"
        )
      end

      BlockMatcher.new(
        example: "#{source} do\nend\n",
        pattern: lambda do |node|
          node.is_a?(Prism::CallNode) &&
            node.block.is_a?(Prism::BlockNode) &&
            same_chain?(node, expected)
        end
      )
    end

    # Whether a receiver chain names the same methods and constants as `expected`, in the same order.
    def self.same_chain?(node, expected)
      case expected
      in nil then node.nil?
      in Prism::CallNode
        node.is_a?(Prism::CallNode) &&
          node.name == expected.name &&
          same_chain?(node.receiver, expected.receiver)
      in Prism::ConstantReadNode | Prism::ConstantPathNode
        !constant_name(node).nil? && constant_name(node) == constant_name(expected)
      else false
      end
    end
    private_class_method :constant_name, :same_chain?

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

    # Adds code as the last lines of the `class ... < Rails::Application` body in config/application.rb,
    # indented 4 spaces, as Rails' own `application` helper does.
    def append_to_application(code)
      inject_into_block(
        'config/application.rb',
        FileContentHelper.class_matcher(superclass: 'Rails::Application'),
        optimize_indentation(code, 4),
        at: :end
      )
    end

    # Adds code as the last lines of the `Rails.application.configure` block in an environment file,
    # indented 2 spaces, so it overrides the Rails defaults above it.
    # Rails' own `environment(code, env:)` adds it at the top instead.
    def append_to_environment(env, code)
      inject_into_block(
        "config/environments/#{env}.rb",
        FileContentHelper.call_matcher('Rails.application.configure'),
        optimize_indentation(code, 2),
        at: :end
      )
    end

    # Overrides Thor's inject_into_class, with the same arguments and options. See inject_into_block.
    def inject_into_class(path, klass, *args, &block)
      inject_into_block(path, FileContentHelper.class_matcher(name: klass), *args, &block)
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
