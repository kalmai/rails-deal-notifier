FactoryBot.define do
  factory :league do
    transient do
      sport { Faker::Sport.sport.downcase }
    end

    full_name { "national #{sport} league" }

    short_name { "n#{sport.split(' ').map(&:first).join }l" }
    start_month { 1 }
    end_month { '10' }

    transient do
      team_count { 2 }
    end

    trait :with_teams do
      after(:create) do |league, evaluator|
        create_list :team, evaluator.team_count, league:
      end
    end
  end
end
