module SentryUser
  extend ActiveSupport::Concern

  included { before_action :set_sentry_user }

  private

  def set_sentry_user
    return unless respond_to?(:current_user) && current_user

    Sentry.set_user(id: current_user.id)
  end
end
