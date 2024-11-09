# frozen_string_literal: true

FactoryBot.define do
  factory :promotion do
    company { Faker::Company.name }
    promo_type { 'bogo' }
    name { "#{promo_type} pizza from '#{company}'" }
    promo_code { "#{promo_type}_#{team.try(:short_name)}" }
    source_url { Faker::Internet.url }
    redemption_limiter { 'seasonal' }
    redemption_count { 1 }
    hours_valid { 24 }
    timing_methods { nil }
    timing_parameters { {} }
    api_methods { %w[won?] }
    api_parameters { {} }

    team

    trait :with_users do
      transient do
        user_region { 'ny' }
        user_count { 1 }
      end

      after(:create) do |promotion, evaluator|
        create_list(:user, evaluator.user_count, :with_contact_methods, region: evaluator.user_region)
        promotion.reload
      end
    end
  end
end
