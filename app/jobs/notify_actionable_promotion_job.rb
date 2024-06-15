# frozen_string_literal: true

class NotifyActionablePromotionJob < ApplicationJob
  queue_as :default

  def perform
    user_promotions = gather_users_and_promotions
  end

  def gather_users_and_promotions
    Promotion.all.each.with_object(Hash.new([])) do |promotion, hsh|
      promotion.users.ids.each { |id| hsh[id] = hsh[id].push(promotion) } if promotion.evaluate
    end
  end
end
