# frozen_string_literal: true

class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token, if: :postman_request # TODO: Remove in dev

  def postman_request
    Rails.env.development? && request.headers['HTTP_USER_AGENT'].downcase.include?('postman')
  end
end
