# frozen_string_literal: true

FactoryBot.define do
  factory :promotion do
    company { Faker::Company.name }
    promo_type { 'bogo' }
    name { "#{promo_type} pizza from '#{company}'" }
    condition { "'hello world' if true" }
    promo_code { "#{promo_type}_#{team.short_name}" }
    source_url { Faker::Internet.url }
    redemption_limiter { 'seasonal' }
    redemption_count { 1 }
    hours_valid { 24 }

    team
  end
end
