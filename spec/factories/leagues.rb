# frozen_string_literal: true

FactoryBot.define do
  factory :league do
    transient do
      sport { Faker::Sport.sport.downcase }
      team_count { 2 }
    end

    full_name { "national #{sport} league" }
    short_name { "n#{sport.split.map(&:first).join}l" }

    trait :with_teams do
      after(:create) do |league, evaluator|
        create_list(:team, evaluator.team_count, league:)
      end
    end
  end
end
