# frozen_string_literal: true

module Interactor
  class UpdateGamesJob < ApplicationJob
    queue_as :high_priority

    def perform(user:)
      RegistrationMailer.with(user:).welcome_email.deliver_later
    end
  end
end
