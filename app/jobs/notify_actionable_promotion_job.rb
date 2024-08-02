# frozen_string_literal: true

class NotifyActionablePromotionJob < ApplicationJob
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
  def timezones_to_evaluate
    user_timezones = User.select('DISTINCT timezone').map(&:timezone)
    user_timezones.sort { |_, tz| tz.utc_offset.abs }
    user_timezones.select { |tz| tz if ActiveSupport::TimeZone.find_tzinfo(tz).now.in(1.hour).hour == 6 }
  end

  def gather_users_and_promotions
    Promotion.all.each.with_object(Hash.new([])) do |promotion, hsh|
      promotion.users.where(timezone: timezones_to_evaluate).each do |user|
        hsh[user.id] = hsh[user.id].push(promotion) if promotion.evaluate(timezone: user.timezone)
      end
    end
  end
end
