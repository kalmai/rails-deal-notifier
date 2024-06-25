# frozen_string_literal: true

module Notify
  module Email
    class TimeSensitiveNotificationJob < ApplicationJob
      queue_as :high_priority

      def perform
        Promotion.where.not(timing_methods: nil).each do |promotion|
          promotion.users.each do |user|
            notification_time = promotion.client.call(
              :playing_today_at,
              promotion.client_params.merge(timezone: user.timezone)
            )
            wait_until = hours_till_notification(notification_time).hours.from_now
            TimeSensitiveMailer.with(user:, promotion:).notify.deliver_later(wait_until:)
          end
        end
      end

      private

      def hours_till_notification(time)
        ((time - Time.current) / 3600).round
      end
    end
  end
end
