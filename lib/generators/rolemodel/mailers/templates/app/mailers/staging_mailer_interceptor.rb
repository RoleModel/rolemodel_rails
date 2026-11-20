class StagingMailerInterceptor
  def self.delivering_email(message)
    message.to = message.to & Rails.configuration.x.whitelisted_emails
    subject_name = Rails.configuration.x.heroku_app_name || 'STAGING'
    message.subject = "#{subject_name} - #{message.subject}"
    message.perform_deliveries = false if message.to.blank?
  end
end
