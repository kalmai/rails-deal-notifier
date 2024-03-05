FactoryBot.define do
  factory :league do
    full_name { "national hockey league" }
    short_name { "nhl" }
    start_month { 1 }
    end_month { "10" }

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
