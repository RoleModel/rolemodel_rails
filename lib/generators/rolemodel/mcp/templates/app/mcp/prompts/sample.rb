# frozen_string_literal: true

module Prompts
  class SamplePrompt < ::MCP::Prompt
    prompt_name 'sample_prompt'
    title 'Sample Prompt'
    description 'Sample prompt description'

    class << self
      def template(_args, _server_context: nil)
        ::MCP::Prompt::Result.new(
          description: 'Sample prompt result description',
          messages: [
            ::MCP::Prompt::Message.new(
              role: 'assistant',
              content: ::MCP::Content::Text.new(instructions_text),
            ),
          ],
        )
      end

      private

      def instructions_text
        <<~TEXT
          This is a sample prompt.

          MCP prompts can return instructions for the agent, which can be used to guide the agent's behavior.
          For example, you might include instructions on how to query a specific resource or use a specific tool.
          Think of it like a system prompt in a conversational agent, but it can be dynamically generated based on the
          context of the request.
        TEXT
      end
    end
  end
end
