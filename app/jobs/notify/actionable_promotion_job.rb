# frozen_string_literal: true

module Notify
  class ActionablePromotionJob < ApplicationJob
    queue_as :default

    def perform
      user_promotions = gather_users_and_promotions
      user_promotions.each do |user_id, promotions|
        user = User.find(user_id)
        wait_until = Time.use_zone(user.timezone) { Time.current.at_beginning_of_day + 6.hours }
        ActionablePromotionMailer.with(user:, promotions:).notify.deliver_later(wait_until:)
      end
    end

    private

    # we run this job every hour, check to see which time zones are 05:00 AM,
    # US time zones don't have 30 hour timezones like India so we're good.
    def timezones_to_evaluate(users:)
      user_timezones = users.select('DISTINCT timezone').map(&:timezone)
      user_timezones.sort { |_, tz| tz.utc_offset.abs }
      user_timezones.select { |tz| tz if ActiveSupport::TimeZone.find_tzinfo(tz).now.in(1.hour).hour == 6 }
    end

    def gather_users_and_promotions
      Promotion.all.each.with_object(Hash.new([])) do |promotion, hsh|
        users = promotion.users
        timezones = timezones_to_evaluate(users:)
        users.where(timezone: timezones).each do |user|
          hsh[user.id] = hsh[user.id].push(promotion) if evaluation(promotion)
        end
      end
    end

    def evaluation(promotion)
      Evaluator::Client.new(promotion:, game: promotion.most_recent_game).evaluate(promotion.api_methods)
    end
  end
end
