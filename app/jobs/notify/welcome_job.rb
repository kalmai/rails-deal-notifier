# frozen_string_literal: true

module Notify
  class WelcomeJob < ApplicationJob
    queue_as :low_priority

    def perform(user:)
      WelcomeMailer.with(user:).send_email.deliver_later
    end
  end
end
