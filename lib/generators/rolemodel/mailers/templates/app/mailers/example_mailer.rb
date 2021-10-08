class ExampleMailer < ApplicationMailer
  default from: 'notifications@example.com'

  def example_email
    @user = params[:user]
    mail(to: @user.email, subject: 'Example Email')
  end
end
