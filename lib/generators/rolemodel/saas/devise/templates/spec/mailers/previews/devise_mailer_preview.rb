# mailers/previews/devise_mailer_preview.rb
class DeviseMailerPreview < ActionMailer::Preview

  def email_changed
    Devise::Mailer.email_changed(User.first)
  end

  if Devise.mappings[:user].confirmable?
    def confirmation_instructions
      Devise::Mailer.confirmation_instructions(User.first, 'faketoken')
    end
  end

  if Devise.mappings[:user].recoverable?
    def password_change
      Devise::Mailer.password_change(User.first)
    end

    def reset_password_instructions
      Devise::Mailer.reset_password_instructions(User.first, 'faketoken')
    end
  end

  if Devise.mappings[:user].lockable?
    def unlock_instructions
      Devise::Mailer.unlock_instructions(User.first, 'faketoken')
    end
  end

  if Devise.mappings[:user].invitable?
    def invitation_instructions
      Devise::Mailer.invitation_instructions(User.first, 'faketoken')
    end
  end
end
