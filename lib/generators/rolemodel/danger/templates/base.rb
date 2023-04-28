# Danger uses 'fail' as part of their DSL, so we need to disable this cop
# rubocop:disable Style/SignalException

declared_trivial = github.pr_title.include? '#trivial' # rubocop:disable Lint/UselessAssignment

# Make it more obvious that a PR is a work in progress and shouldn't be merged yet
warn('PR is classed as Work in Progress') if github.pr_title.include? '[WIP]'

# Warn when there is a big PR
warn('Big PR') if git.lines_of_code > 500

# Don't let testing shortcuts get into master by accident
fail('fdescribe left in tests') if `grep -r fdescribe spec/**/*_spec.rb `.length > 1
fail('fit left in tests') if `grep -r fit spec/**/*_spec.rb `.length > 1
fail('focus left in tests') if `grep -r focus spec/**/*_spec.rb `.length > 1

# rubocop:enable Style/SignalException
