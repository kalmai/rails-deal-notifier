# frozen_string_literal: true

class Promotion < ApplicationRecord
  # as per https://www.google.com/search?q=types+of+discounts
  enum :promo_type, %i[
    bogo free_shipping percentage_discounts seasonal_discounts
    cash_discount free_gifts volume_discounts contractual_discount
    automatic_coupons referral_discounts category_discounts
    customer_discounts quantity_discount trade_discount bundle_discounts
    coupon_codes order_discounts price_bundling brand_discounts
    limited_time_offers flash_sales loyalty_points rebate try_before_you_buy
  ]
  enum :redemption_limiter, %i[seasonal lifetime number]

  belongs_to :team
end
