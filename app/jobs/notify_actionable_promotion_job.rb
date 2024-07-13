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

  def gather_users_and_promotions
    Promotion.all.each.with_object(Hash.new([])) do |promotion, hsh|
      promotion.users.each do |user|
        hsh[user.id] = hsh[user.id].push(promotion) if promotion.evaluate(timezone: user.timezone)
      end
    end
  end
end
