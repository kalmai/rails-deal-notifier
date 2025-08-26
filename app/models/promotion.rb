# frozen_string_literal: true

class Promotion < ApplicationRecord
  # as per https://www.google.com/search?q=types+of+discounts
  enum :promo_type, %i[
    automatic_coupons bogo brand_discounts bundle_discounts cash_discount
    category_discounts contractual_discount coupon_codes customer_discounts flash_sales
    free_gifts free_shipping limited_time_offers loyalty_points order_discounts
    percentage_discounts price_bundling quantity_discount rebate referral_discounts
    seasonal_discounts sweepstakes trade_discount try_before_you_buy volume_discounts
  ]
  enum :redemption_limiter, %i[seasonal lifetime number monthly]
  validates :company, presence: true

  belongs_to :team
  has_many :subscriptions, dependent: :destroy
  has_many :users, through: :subscriptions, dependent: :destroy

  def most_recent_game
    Game.most_recent_game(team_id: team.id)
  end

  def next_game
    Game.next_game(team_id: team.id)
  end

  def evaluate_most_recent_game
    game = most_recent_game
    return false if game.nil?
    return false unless Time.current.between?(game.utc_start_time, game.utc_start_time + hours_valid.hours)

    Evaluator::Client.new(promotion: self, game:).evaluate(api_methods)
  end

  def evaluate_next_game
    return false if next_game.nil?

    Evaluator::Client.new(promotion: self, game: next_game).evaluate(timing_methods)
  end
end
