# frozen_string_literal: true

module BlazerExtensions
  module DataSource
    # add Rails.env.test? so reports can run when testing
    def adapter_instance # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      @adapter_instance ||= begin
        unless settings['url'] ||
               Rails.env.development? ||
               Rails.env.test? ||
               ['bigquery', 'athena', 'snowflake',
                'salesforce'].include?(settings['adapter'])
          raise Blazer::Error, "Empty url for data source: #{id}"
        end

        raise Blazer::Error, 'Unknown adapter' unless Blazer.adapters[adapter]

        Blazer.adapters[adapter].new(self)
      end
    end
  end
end
