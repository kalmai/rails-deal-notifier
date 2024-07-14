# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'

class Promotion < ApplicationRecord
  extend T::Sig

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

  sig { params(timezone: String).returns(T::Boolean) }
  def evaluate(timezone:)
    T.must(api_methods).all? { |method| client(timezone).call(method) }
  end

  sig { params(timezone: String, single_method: String).returns(T::Boolean) }
  def evaluate_single_method(timezone:, single_method:)
    client(timezone).call(single_method)
  end

  private

  sig { params(timezone: String).returns(T::Hash[String, String]) }
  def client_params(timezone)
    { short_name: team.try(:short_name), timezone: }.merge!(api_parameters, try(:timing_parameters)).with_indifferent_access
    # %i[timing_parameters api_parameters].map { p.try _1 }.reduce({}, :merge)
  end

  sig { params(timezone: String).returns(T.any(Mls::Client, Nhl::Client)) }
  def client(timezone)
    "#{team.try(:league).try(:short_name).titleize}::Client".constantize.new(args: client_params(timezone))
  end
end
