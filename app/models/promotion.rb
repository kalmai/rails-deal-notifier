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
  enum :redemption_limiter, %i[seasonal lifetime number]
  validates :company, presence: true

  belongs_to :team

  def evaluate
    client = "#{team.league.short_name.titleize}::Client".constantize
    api_methods.all? do |method|
      client.call(method, client_params)
    end
  end

  def client_params
    { short_name: team.short_name }.merge!(api_parameters).with_indifferent_access
  end
end
