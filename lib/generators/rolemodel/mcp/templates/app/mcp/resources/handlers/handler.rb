# frozen_string_literal: true

module Resources
  module Handlers
    class Handler
      include ActiveModel::Attributes
      include ActiveModel::API

      attribute :server_context
      attribute :path, :string

      validates :path, presence: { message: 'is required' } # rubocop:disable Rails/I18nLocaleTexts

      class << self
        def mime_type(mime_type = nil)
          @mime_type = mime_type if mime_type
          @mime_type
        end

        def schema(schema = nil)
          @schema = schema if schema
          @schema
        end

        def handles?(uri)
          uri.start_with?(schema)
        end

        def call(params, server_context)
          handler = new(params[:uri].sub(schema, ''), server_context)

          unless handler.valid?
            raise MCP::Server::RequestHandlerError.new(
              handler.errors.full_messages.join(', '),
              params,
              error_type: :invalid_params
            )
          end

          [{ uri: params[:uri], mimeType: mime_type, text: handler.handle }]
        end
      end

      def initialize(path, server_context = nil)
        super()
        self.path = path
        self.server_context = server_context
      end

      private

      def no_extra_path_parts
        return if @extra.blank?

        errors.add(:base, "Too many uri parts: #{@extra.join('/')}.")
      end
    end
  end
end
