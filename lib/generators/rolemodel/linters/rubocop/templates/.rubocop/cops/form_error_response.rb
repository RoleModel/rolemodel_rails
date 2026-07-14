# frozen_string_literal: true

module Cops
  # Custom Cop to Ensure Form Error Response Statuses
  #
  # There are three levels of matching here:
  # Methods (def on_if)
  # This scans code and only stops on the method specified.
  # E.G. `on_if` will only move into the below checks when it encounters an if statement.
  #
  # Node matcher (def_node_matcher :form_error)
  # This scans the block of code (in this case, the else branch of the if block)
  # using AST (Abstract Tree Syntax) to match certain patterns
  #
  # Regex
  # This checks the specific matching line to ensure it meets our expectations
  class FormErrorResponse < RuboCop::Cop::Base
    extend RuboCop::Cop::AutoCorrector

    def self.rack_version
      Gem.loaded_specs['rack'].version
    end

    def self.http_status
      if rack_version >= '3.1'
        :unprocessable_content
      else
        :unprocessable_entity
      end
    end

    # Match code in the else branch that either: is the only line and looks like `render :something, ...`
    # or is not the first line and looks like the same.
    def_node_matcher :form_error, <<~PATTERN
      {(... $(send nil? :render (:sym _) ...)) | $(send nil? :render (:sym _) ...)}
    PATTERN

    MSG = "Use status: :#{self.http_status} for invalid form requests."

    # Ensure the render is returning the correct status, otherwise add the offense
    STATUS_PAIR = /\(pair\s+\(sym :status\)\s+\(sym :#{self.http_status}\)\)/m

    # Only check within if blocks
    def on_if(node)
      form_error(node.else_branch) do |name|
        next if name.to_s.match?(STATUS_PAIR)

        add_offense(name) do |corrector|
          corrector.insert_after(name, ", status: :#{self.class.http_status}")
        end
      end
    end
  end
end
