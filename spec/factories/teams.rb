# frozen_string_literal: true

FactoryBot.define do
  factory :team do
    transient do
      promotion_count { 2 }
    end

    full_name { Faker::Sports::Football.team.downcase }
    short_name { full_name.split.map(&:first).join }
    region { Faker::Address.state.downcase }
    country { 'us' }

    league

    trait :with_promotions do
      after(:create) do |team, evaluator|
        create_list(:promotion, evaluator.promotion_count, team:)
      end
    end
  end
end
