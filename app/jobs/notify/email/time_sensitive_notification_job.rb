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
            email = user.contact_methods&.first&.contact_detail
            next unless today_for_user?(notification_time, user.timezone)

            puts "#{email}: #{notification_time}"
          end
        end
      end

      def today_for_user?(utc_time, user_timezone)
        time = utc_time.in_time_zone(user_timezone)
        time.before?(Time.now.end_of_day)
      end
    end
  end
end
