# frozen_string_literal: true

module Notify
  module Email
    class TimeSensitiveNotificationJob < ApplicationJob
      queue_as :high_priority

      def perform
        Promotion.where.not(timing_methods: nil).each do |promotion|
          notification_time = promotion.utc_notification_time
          next unless notification_time

          users_to_be_notified = promotion.users
          users_to_be_notified.each do |user|
            next unless today_for_user?(notification_time, user.timezone)

            wait_until = hours_till_notification(notification_time).hours.from_now
            TimeSensitiveMailer.with(user:, promotion:).notify.deliver_later(wait_until:)
          end
        end
      end

      private

      def today_for_user?(utc_time, user_timezone)
        time = utc_time.in_time_zone(user_timezone)
        time.before?(Time.now.end_of_day)
      end

      def hours_till_notification(utc_time)
        ((utc_time - Time.current) / 3600).round
      end
    end
  end
end
