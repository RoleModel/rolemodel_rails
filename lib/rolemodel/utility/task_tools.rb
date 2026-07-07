require 'benchmark'

module Rolemodel
  module Utility
    module TaskTools
      PROGRESS = %w[⠏ ⠇ ⠧ ⠦ ⠴ ⠼ ⠸ ⠹ ⠙ ⠋].cycle

      # based on the migration helper of the same name
      def say_with_time(message, &)
        say message
        time = Benchmark.measure(&)
        say '%.4fs' % time.real, subitem: true
      end

      # based on the migration helper of the same name
      def say(message, subitem: false)
        puts "#{subitem ? '   ->' : '--'} #{message}" # rubocop:disable Rails/Output
      end

      ##
      # Indicate the progress of a long-running process
      #
      # Usage (with a known total):
      # 100.times do |i|
      #   indicate_progress(i, 100)
      # end
      #
      # Only update every 'report_interval' iteration for eye-trackable animation speed
      # Also displays a completion percentage if a total is provided
      def indicate_progress(index, total = nil, report_interval: 9)
        return unless (index % report_interval).zero?

        print("#{PROGRESS.next} #{to_percent(index, total) if total}\r") # rubocop:disable Rails/Output
      end

      ##
      # Enables a pattern for dry-run mode in tasks. Assumes usage of other utility methods
      # like `say_with_time` and `indicate_progress` that provide user feedback, separate from the actions they perform.
      #
      # Tasks can be updated to support this mode by adding `unless dry_run?` to lines of code that write to the file system or database.
      def dry_run?
        ENV['DRY_RUN'].present?
      end

      ##
      # Improves the usability of Rake::Task arguments which are positional and don't support default values.
      # This method allows invocation with skipped arguments via `_` and supports a defaults hash.
      def sanitize_arguments(args, defaults = {})
        defaults.merge(ArgumentSanitizer.new(args).to_h)
      end

      private

      def to_percent(index, total)
        '%3.f%%' % (index / total.to_f * 100.0)
      end
    end

    class ArgumentSanitizer
      def initialize(args)
        @args = args.to_h
      end

      def to_h
        @args.transform_values { it.to_s.strip.match?('_') ? nil : it.to_s.strip }.compact
      end
    end
  end
end
