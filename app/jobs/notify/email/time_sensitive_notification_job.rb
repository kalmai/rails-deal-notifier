# frozen_string_literal: true

module Notify
  module Email
    class TimeSensitiveNotificationJob < ApplicationJob
      queue_as :high_priority

      def perform
        # TODO: should look into finding users this way
        # users = User.joins(:promotions).where.not('promotions.timing_methods': nil)
        Promotion.where.not(timing_methods: nil).each do |promotion|
          notification_time = promotion.utc_notification_time
          next unless notification_time

          users_to_be_notified = promotion.users
          users_to_be_notified.each do |user|
            email = user.contact_methods&.first&.contact_detail
            next unless today_for_user?(notification_time, user.timezone)

            # this is how we're going to send emails at a certain time
            # RegistrationMailer.with(user:).welcome_email.deliver_later(wait_until: Time.zone.now + 1.minute)
            # getting the time difference will be something like
            # diff = Time.zone.now - notification_time # this is in seconds apparently
            # hrs = (diff.abs/60/60)
            # RegistrationMailer.with(user:).welcome_email.deliver_later(wait_until: Time.zone.now + hrs)
            # Time.at(Time.zone.now.in(hrs.hours))
            # verify above and timezone by calling .zone on the Time object above
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
