# frozen_string_literal: true

class NotifyActionablePromotionJob < ApplicationJob
  queue_as :default

  def perform
    user_promotions = gather_users_and_promotions
    schedule_notifications(user_promotions:)
    update_notified_user_id_list(user_promotions:)
  end

  private

  def schedule_notifications(user_promotions:)
    user_promotions.each do |user_id, promotions|
      next if user_id.in?(Rails.cache.read('notified_user_ids').to_a)

      user = User.find(user_id)
      wait_until = Time.use_zone(user.timezone) do
        Time.current.change(hours: user.notification_hour, minutes: user.notification_minute)
      end
      ActionablePromotionMailer.with(user:, promotions:).notify.deliver_later(wait_until:)
    end
  end

  def update_notified_user_id_list(user_promotions:)
    Rails.cache.write('notified_user_ids', Rails.cache.read('notified_user_ids').to_a + user_promotions.keys)
  end

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
        hsh[user.id] = hsh[user.id].push(promotion) if promotion.evaluate(timezone: user.timezone)
      end
    end
  end
end
