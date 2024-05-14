# frozen_string_literal: true

# *** NOTE ABOUT ORDERING OF discard_on/retry_on
# https://api.rubyonrails.org/v7.1.3.2/classes/ActiveJob/Exceptions/ClassMethods.html#method-i-retry_on
# 'retry_on' and 'discard_on' handlers are searched from bottom to top, and up the class hierarchy.
# The handler of the first class for which exception.is_a?(klass) holds true is the one invoked, if any.

# Add retry at ActiveJob::Base level to ensure all jobs retry 25 times by default regardless
# of where the job originates from
# Note: Rails 6 should use :exponentially_longer
ActiveJob::Base.retry_on StandardError, wait: :polynomially_longer, attempts: 25

# Automatically retry jobs that encountered a deadlock
ActiveJob::Base.retry_on ActiveRecord::Deadlocked

ActiveJob::Base.discard_on ActiveJob::DeserializationError
ActiveJob::Base.discard_on ActiveRecord::RecordNotFound
