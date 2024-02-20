# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  # default from: 'UPDATE@gmail.com'
  # layout 'mailer'

  def welcome_email
    mail(to: params[:email], subject: 'Welcome to Sport DealNotifier!')
  end
end
