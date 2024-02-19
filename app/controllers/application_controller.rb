# frozen_string_literal: true

class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token, if: :postman_request # TODO: Remove in dev

  def send_email
    ApplicationMailer.welcome_email.deliver_now
    render plain: 'OK'
  end

  def postman_request
    binding.pry
    Rails.env.development? && request.headers['HTTP_USER_AGENT'].downcase.include?('postman')
  end
end
