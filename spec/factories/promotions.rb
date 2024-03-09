# frozen_string_literal: true

FactoryBot.define do
  factory :promotion do
    transient do
      expression_count { 2 }
    end
    company { Faker::Company.name }
    promo_type { 'bogo' }
    name { "#{promo_type} pizza from '#{company}'" }
    promo_code { "#{promo_type}_#{team.short_name}" }
    source_url { Faker::Internet.url }
    redemption_limiter { 'seasonal' }
    redemption_count { 1 }
    hours_valid { 24 }

    team

    trait :cbj_moo_moo_carwash do
      company { 'Moo Moo Express Car Wash' }
      promo_type { 'free_gifts' }
      name { 'Moo Moo Express Car Wash 3rd Period Goal' }
      promo_code { nil }
      source_url { 'https://www.nhl.com/bluejackets/fans/gameday-central' }
      # requirements do
      #   [
      #     'sign up on gameday', 'one hour before the start of the game',
      #     'or till end of game', 'sign up here: https://moomoocarwash.com/cbj/',
      #     'enter cellphone number'
      #   ]
      # end
    end

    trait :with_expressions do
      after(:create) do |promotion, evaluator|
        create_list(:expression, evaluator.expression_count, promotion:)
      end
    end
  end
end
