# frozen_string_literal: true

module Tools
  class Sample < MCP::Tool
    tool_name 'sample_tool'
    title 'Sample Tool'
    description 'Sample tool description'
    input_schema(
      properties: {
        name: { type: 'string', minLength: 1 },
      },
      required: ['name'],
    )
    annotations(
      read_only_hint: true,
      destructive_hint: false,
      idempotent_hint: true,
      open_world_hint: false,
      title: 'Sample Tool',
    )

    class << self
      def call(name:, server_context:)
        payload = payload_for(name)

        MCP::Tool::Response.new(
          [{ type: 'text', text: payload.to_json }],
          structured_content: { sample: payload },
        )
      end

      private

      def payload_for(name)
        {
          time: Time.current.iso8601,
          user_count: User.count
        }
      end
    end
  end
end
