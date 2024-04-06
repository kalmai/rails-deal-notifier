# frozen_string_literal: true

module Registration
  class NotifyJob < ApplicationJob
    queue_as :low_priority

    def perform(user:)
      RegistrationMailer.with(user:).welcome_email.deliver_later
    end
  end
end
