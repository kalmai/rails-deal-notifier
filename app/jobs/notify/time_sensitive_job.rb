# frozen_string_literal: true

module Notify
  class TimeSensitiveJob < ApplicationJob
    queue_as :high_priority

    def perform
      Promotion.where.not(timing_parameters: {}).each do |promotion|
        start_time = promotion.next_game&.utc_start_time
        next unless start_time.present? && promotion.evaluate_next_game

        offset = promotion.timing_parameters['minutes_before'].to_i
        handle_enqueing(promotion:, start_time:, offset:)
      end
    end

    private

    def handle_enqueing(promotion:, start_time:, offset:)
      promotion.users.each do |user|
        notification_time = start_time.in_time_zone(user.timezone) - offset.minutes
        next unless notification_time.in_time_zone(user.timezone).today?

        TimeSensitiveMailer.with(user:, promotion:).notify.deliver_later(wait_until: notification_time)
      end
    end
  end
end
