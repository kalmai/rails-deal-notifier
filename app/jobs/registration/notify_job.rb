# frozen_string_literal: true

module Registration
  class NotifyJob < ApplicationJob
    queue_as :low_priority

    def perform(user:)
      ApplicationMailer.with(email: user.contact_methods.last.contact_detail).welcome_email.deliver_now
    end
  end
end
