# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'UPDATE@gmail.com'
  # layout 'mailer'

  def welcome_email
    mail(to: 'UPDATE@gmail.com', subject: 'Welcome to My Awesome Site')
  end
end
