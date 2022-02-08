class StagingMailerInterceptor
  def self.delivering_email(message)
    whitelisted_emails = ENV['WHITELISTED_EMAILS'].split(',').map(&:strip)
    message.to = message.to & whitelisted_emails
    message.subject = "STAGING - #{message.subject}"
    message.perform_deliveries = false if message.to.blank?
  end
end
