# frozen_string_literal: true

class TimeSensitiveNotificationMailer < ApplicationMailer
  def welcome_email
    mail(to: params[:email], subject: 'Time Sensitive Promotion Reminder')
  end
end
