# frozen_string_literal: true

require 'rubocop'

module Cops
  class NoChromeTag < RuboCop::Cop::Base
    include RuboCop::Cop::RangeHelp
    extend RuboCop::Cop::AutoCorrector

    MSG = 'The :chrome tag is only for testing, and should not be checked into the repository.'
    RESTRICT_ON_SEND = %i[describe context it feature scenario].freeze

    def on_send(node)
      node.arguments.each do |a|
        if a.sym_type? && a.value == :chrome
          range = range_with_surrounding_comma(a.source_range)
          add_offense(range) do |corrector|
            corrector.replace(range, '')
          end
        end

        next unless a.hash_type?

        a.pairs.each do |pair|
          next unless pair.key.value == :chrome

          range = range_with_surrounding_comma(pair.source_range)
          add_offense(range) do |corrector|
            corrector.replace(range, '')
          end
        end
      end
    end

    def range_with_surrounding_comma(source_range)
      buffer = source_range.source_buffer
      src = buffer.source
      end_pos = source_range.end_pos
      comma_index = src[...end_pos].rindex(/\s*,\s*/)

      Parser::Source::Range.new(buffer, comma_index, end_pos)
    end
  end
end
