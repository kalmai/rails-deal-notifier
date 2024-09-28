# frozen_string_literal: true

module Notify
  module Email
    class TimeSensitiveNotificationJob < ApplicationJob
      queue_as :high_priority

      def perform
        Promotion.where('array_length(timing_methods, 1) is not null').each do |promotion|
          promotion.users.each do |user|
            time_results = time_method_results(timezone: user.timezone, promotion:)

            wait_until = hours_till_notification(time_results.delete('playing_today_at')).hours.from_now
            next unless time_results.values.all?

            TimeSensitiveMailer.with(user:, promotion:).notify.deliver_later(wait_until:)
          end
        end
      end

      private

      def time_method_results(timezone:, promotion:)
        promotion.timing_methods.index_with { |single_method| promotion.evaluate(timezone:, single_method:) }
      end

      def hours_till_notification(time)
        ((time - Time.current) / 3600).round
      end
    end
  end
end
