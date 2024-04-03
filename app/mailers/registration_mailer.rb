# frozen_string_literal: true

class RegistrationMailer < ApplicationMailer
  def welcome_email
    @user = params[:user]
    params[:email] = @user.contact_methods.detail_for(type: 'email')
    mail(to: params[:email], subject: 'Welcome to Sports DealNotifier')
  end
end
