# frozen_string_literal: true

require 'blazer_extensions/data_source'

Rails.application.config.to_prepare do
  Blazer::DataSource.prepend BlazerExtensions::DataSource
end
