# Preview all emails at http://localhost:3000/rails/mailers/example_mailer
class ExampleMailerPreview < ActionMailer::Preview
  def example_email
    ExampleMailer.with(user: User.first).example_email
  end
end
