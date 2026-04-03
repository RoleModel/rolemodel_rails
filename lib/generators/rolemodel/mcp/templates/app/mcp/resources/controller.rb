# frozen_string_literal: true

module Resources
  class Controller
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

      def serves?(uri)
        uri.start_with?(schema)
      end

      def call(params, server_context)
        controller = new(params[:uri].sub(schema, ''), server_context)

        unless controller.valid?
          raise ::MCP::Server::RequestHandlerError.new(
            controller.errors.full_messages.join(', '),
            params,
            error_type: :invalid_params
          )
        end

        [{ uri: params[:uri], mimeType: mime_type, text: controller.serve }]
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
