# frozen_string_literal: true

module Resources
  module Handlers
    class Docs < Handler
      FILES = {
        'SAMPLE_DOC.md' => Rails.root.join('app/mcp/resources/docs/blazer-documentation.md'),
      }.freeze

      mime_type 'text/markdown'
      schema 'docs://'

      attribute :file_path

      validates :file_path, presence: { message: ->(handler, _) { "Unknown docs resource: #{handler.path}" } }
      validate :file_exists

      def initialize(path, _server_context = nil)
        super
        self.file_path = FILES[path]
      end

      def self.resource_list
        [
          ::MCP::Resource.new(
            uri: 'docs://SAMPLE_DOC.md',
            name: 'sample_doc',
            title: 'Sample Resource',
            description: 'Sample resource',
            mime_type: mime_type,
          ),
        ]
      end

      def handle
        file_path.read
      end

      private

      def file_exists
        return if file_path.blank? || file_path.exist?

        errors.add(:file_path, "Missing docs file for #{path}")
      end
    end
  end
end
