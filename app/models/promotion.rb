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
  has_many :subscriptions
  has_many :users, through: :subscriptions

  def evaluate(timezone:, single_method: nil)
    eval_client = client(timezone)
    single_method ? eval_client.call(single_method) : api_methods.all? { |method| eval_client.call(method) }
  end

  private

  def client_params(timezone)
    { short_name: team.short_name, timezone: }.merge!(api_parameters, timing_parameters).with_indifferent_access
  end

  def client(timezone)
    "#{team.league.short_name.titleize}::Client".constantize.new(args: client_params(timezone))
  end
end
