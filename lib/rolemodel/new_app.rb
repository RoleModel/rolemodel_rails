# frozen_string_literal: true

require 'rails/command'
require 'rails/commands/application/application_command'

module Rolemodel
  module NewApp
    DEFAULTS = %W[
      --database=postgresql
      --javascript=webpack
      --skip-kamal
      --skip-solid
      --skip-test
      --template=#{File.expand_path('new_app/template.rb', __dir__)}
    ].freeze

    def self.argv(argv)
      scrubbed = Rails::Generators::ARGVScrubber.new(argv).prepare!
      scrubbed.take(1) + DEFAULTS + scrubbed.drop(1)
    end
  end
end
