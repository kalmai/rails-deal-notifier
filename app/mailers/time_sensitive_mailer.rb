# frozen_string_literal: true

class TimeSensitiveMailer < ApplicationMailer
  def notify
    @user = params[:user]
    @promotion = params[:promotion]
    to = @user.contact_methods.detail_for(type: 'email')
    mail(to:, subject: 'Sports DealNotifier: Action Suggested!')
  end
end
