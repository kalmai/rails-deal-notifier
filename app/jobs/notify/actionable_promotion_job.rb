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
      in_season_promotions.each.with_object(Hash.new([])) do |promotion, hsh| # rubocop:disable Lint/SharedMutableDefault
        users = promotion.users
        timezones = timezones_to_evaluate(users:)
        users.where(timezone: timezones).each do |user|
          hsh[user.id] = hsh[user.id].push(promotion) if evaluation(promotion)
          # hsh[user.id] = hsh[user.id].push(promotion) if should_nofify?(user.timezone, promotion)
        end
      end
    end

    def evaluation(promotion)
      game = promotion.most_recent_game
      return false unless game

      Evaluator::Client.new(promotion:, game:).evaluate(promotion.api_methods)
    end

    def in_season_promotions
      Promotion.all.select { |promo| promo.team.league.in_season? }
    end

    def should_nofify?(timezone, promotion)
      return false if promotion.most_recent_game.utc_start_time.in_time_zone(timezone).yesterday?

      evaluation(promotion)
    end
  end
end
