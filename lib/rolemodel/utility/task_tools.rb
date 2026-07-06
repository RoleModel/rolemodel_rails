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
      # Enables a pattern for dry-run mode in tasks. Assumes usage of of other utility methods
      # like `say_with_time` and `indicate_progress` that provide user feedback, separate from the actions they perform.
      #
      # Tasks can be updated to support this mode by adding `unless dry_run?` to lines of code that write to the file system or database.
      #
      # e.g.
      #   namespace :clear do
      #     desc 'Delete all non-current report records'
      #     task expired: :total do
      #       say_with_time "Detecting & Deleting Expired Reports among #{@total} Total" do
      #         deleted_reports = 0
      #         GeneratedReport.find_each.with_index do |report, index|
      #           indicate_progress(index, @total)
      #           next if report.current?
      #
      #           report.destroy unless dry_run?
      #           deleted_reports += 1
      #         end
      #         say "#{deleted_reports}/#{@total} Records Deleted"
      #       end
      #     end
      #   end
      def dry_run?
        ENV['DRY_RUN'].present?
      end

      ##
      # Improves the usability of Rake::Task arguments which are positional and don't support default values.
      # This method allows invocation with skipped arguments via `_` and supports default values for any missing arguments.
      #
      # e.g.
      #   namespace :users do
      #     desc 'Seed a dev user with the given name and email'
      #     task :dev, %i[name email] => :environment do |_, args|
      #       name, email = sanitize_arguments(args, name: 'RoleModel', email: 'it-support@rolemodelsoftware.com').values_at(:name, :email)
      #       say_with_time "Seeding Dev User (name: #{name}, email: #{email}, role: Admin)" do
      #         User.find_or_create(name:, email:, role: 'admin') unless dry_run?
      #       end
      #     end
      #   end
      #
      # $ DRY_RUN=true rake users:dev[_,outlawandy@gmail.com]
      #   -- Seeding Dev User (name: RoleModel, email: outlawandy@gmail.com, role: Admin)
      #     -> 0.0000s
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
