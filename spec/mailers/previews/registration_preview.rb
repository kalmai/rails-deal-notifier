# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/registration
class RegistrationPreview < ActionMailer::Preview
  def welcome_email
    RegistrationMailer.with(user: User.first).welcome_email
  end
end
