# frozen_string_literal: true

require 'date'
require 'fileutils'
require_relative 'version'

module Rolemodel
  # Persistent record of which rolemodel_rails generators have been applied to
  # a consuming app. Entries live in a marker-delimited managed block inside
  # config/initializers/rolemodel_generators.rb and are read back through
  # Rails' own config.generators option resolution (Rails::Generators.options).
  #
  # Deliberately a plain module with no generator requires: it is loaded from
  # the engine path (via GeneratorBase) and must stay safe to load there.
  module Registry
    # Raised when the initializer exists but its managed-block markers are
    # missing — the writer never guesses where entries belong.
    class MissingMarkersError < StandardError; end

    INITIALIZER_PATH = 'config/initializers/rolemodel_generators.rb'
    BEGIN_MARKER = '# rolemodel_rails:begin'
    END_MARKER = '# rolemodel_rails:end'

    ENTRY_PATTERN = /\A\s*g\.rolemodel (?<key>\w+):\s*(?<value>true|false)\b/

    FILE_TEMPLATE = <<~RUBY.freeze
      # frozen_string_literal: true

      # Records which rolemodel_rails generators have been applied to this app.
      # Generators read this through Rails' own config.generators mechanism.
      # Set an entry to `false` to permanently opt out of a coupling or
      # prevent re-recording; delete the file and run rails g rolemodel:registry
      # to rebuild it. Only edit between the markers if you know what you're doing.
      Rails.application.config.generators do |g|
        #{BEGIN_MARKER}
        #{END_MARKER}
      end
    RUBY

    class << self
      # Registry key for a generator class: its generator namespace with the
      # rolemodel: prefix stripped and colons underscored.
      # Rolemodel::WebpackGenerator      -> :webpack
      # Rolemodel::Optics::BaseGenerator -> :optics_base
      def key_for(generator_class)
        generator_class.namespace.delete_prefix('rolemodel:').tr(':', '_').to_sym
      end

      # Whether a key is recorded, read through Rails::Generators.options —
      # the hash the framework populates from the consuming app's
      # config.generators. Guarded: returns false (never raises) in unbooted
      # or no-config contexts, and for an explicit false opt-out entry.
      def recorded?(key)
        namespace = configured_namespace
        return false unless namespace

        namespace[key.to_sym] == true
      end

      # Upserts the entry line for +key+ inside the managed block of the
      # initializer under +destination_root+, creating the whole file when
      # absent. Returns :recorded, or :skipped_opt_out when the existing entry
      # is an explicit false (the user's persistent opt-out — never overwritten).
      def record(key, destination_root:, comment: default_comment)
        path = initializer_path(destination_root)
        write_template(path) unless File.exist?(path)

        block = ManagedBlock.new(path)
        return :skipped_opt_out if block.opt_out?(key)

        block.upsert(key, comment)
        :recorded
      end

      # Deletes the entry line for +key+ (used by rails destroy). Returns
      # :removed, :skipped_opt_out for an explicit false entry, or
      # :not_recorded when there is nothing to remove.
      def remove(key, destination_root:)
        path = initializer_path(destination_root)
        return :not_recorded unless File.exist?(path)

        block = ManagedBlock.new(path)
        return :not_recorded unless block.entry?(key)
        return :skipped_opt_out if block.opt_out?(key)

        block.delete(key)
        :removed
      end

      private

      def configured_namespace
        return nil unless defined?(::Rails::Generators)
        return nil unless ::Rails::Generators.respond_to?(:options)

        options = ::Rails::Generators.options
        options[:rolemodel] if options.is_a?(Hash)
      end

      def default_comment
        "rolemodel_rails #{Rolemodel::VERSION}, #{Date.today.iso8601}"
      end

      def initializer_path(destination_root)
        File.expand_path(INITIALIZER_PATH, destination_root)
      end

      def write_template(path)
        FileUtils.mkdir_p(File.dirname(path))
        File.write(path, FILE_TEMPLATE)
      end
    end

    # Line-level editor for the marker-delimited block of one initializer
    # file. All mutation is anchored to entry lines between the markers;
    # everything outside them is preserved byte for byte.
    class ManagedBlock
      def initialize(path)
        @path = path
        @lines = File.read(path).lines
        @begin_index = marker_index(BEGIN_MARKER)
        @end_index = marker_index(END_MARKER)
        validate_markers!
      end

      def entry?(key)
        !entry_index(key).nil?
      end

      def opt_out?(key)
        index = entry_index(key)
        index ? ENTRY_PATTERN.match(@lines[index])[:value] == 'false' : false
      end

      def upsert(key, comment)
        entry = entry_line(key, comment)
        index = entry_index(key)

        if index
          @lines[index] = entry
        else
          @lines.insert(insertion_index(key), entry)
        end

        save
      end

      def delete(key)
        @lines.delete_at(entry_index(key))
        save
      end

      private

      def marker_index(marker)
        @lines.index { |line| line.strip == marker }
      end

      def validate_markers!
        return if @begin_index && @end_index && @begin_index < @end_index

        raise MissingMarkersError, <<~MESSAGE
          #{@path} exists but its managed-block markers are missing.
          Re-add `#{BEGIN_MARKER}` and `#{END_MARKER}` lines inside the
          `Rails.application.config.generators` block (entries go between them),
          or delete the file and run `bin/rails generate rolemodel:registry` to rebuild it.
        MESSAGE
      end

      def entry_range
        (@begin_index + 1)...@end_index
      end

      def entry_index(key)
        entry_range.find do |index|
          ENTRY_PATTERN.match(@lines[index])&.[](:key) == key.to_s
        end
      end

      # New entries slot in alphabetically among existing entry lines, or at
      # the end of the block when no later key exists.
      def insertion_index(key)
        entry_range.find do |index|
          match = ENTRY_PATTERN.match(@lines[index])
          match && match[:key] > key.to_s
        end || @end_index
      end

      def entry_line(key, comment)
        indent = @lines[@begin_index][/\A[ \t]*/]
        "#{indent}g.rolemodel #{key}: true # #{comment}\n"
      end

      def save
        File.write(@path, @lines.join)
      end
    end
  end
end
