# frozen_string_literal: true

class ApplicationController < ActionController::Base
  def send_email
    ApplicationMailer.welcome_email.deliver_now
    render plain: 'OK'
  end
end
