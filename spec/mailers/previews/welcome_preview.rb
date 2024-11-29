# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/registration
class WelcomePreview < ActionMailer::Preview
  def send_email
    WelcomeMailer.with(user: User.first).send_email
  end
end
