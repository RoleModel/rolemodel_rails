# frozen_string_literal: true

# Add retry at ActiveJob::Base level to ensure all jobs retry 25 times by default regardless
# of where the job originates from
# Note: Rails 6 should use :exponentially_longer
ActiveJob::Base.retry_on StandardError, wait: :polynomially_longer, attempts: 25

ActiveJob::Base.discard_on ActiveJob::DeserializationError
ActiveJob::Base.discard_on ActiveRecord::RecordNotFound
