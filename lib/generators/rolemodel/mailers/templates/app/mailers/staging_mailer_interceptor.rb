class StagingMailerInterceptor
  def self.delivering_email(message)
    whitelisted_emails = ENV['WHITELISTED_EMAILS'].split(',').map(&:strip)
    message.to = message.to & whitelisted_emails
    subject_name =  ENV['HEROKU_APP_NAME'].presence || 'STAGING'
    message.subject = "#{subject_name} - #{message.subject}"
    message.perform_deliveries = false if message.to.blank?
  end
end
