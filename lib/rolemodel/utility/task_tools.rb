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

      private

      def to_percent(index, total)
        '%3.f%%' % (index / total.to_f * 100.0)
      end
    end
  end
end
