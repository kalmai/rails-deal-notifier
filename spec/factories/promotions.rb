# frozen_string_literal: true

FactoryBot.define do
  factory :promotion do
    company { Faker::Company.name }
    promo_type { 'bogo' }
    name { "#{promo_type} pizza from '#{company}'" }
    promo_code { "#{promo_type}_#{team.short_name}" }
    source_url { Faker::Internet.url }
    redemption_limiter { 'seasonal' }
    redemption_count { 1 }
    hours_valid { 24 }
    timing_methods { nil }
    timing_parameters { {} }
    api_methods { %w[won?] }
    api_parameters { {} }

    team

    trait :with_league_team_and_users do
      transient do
        league_abbr { 'mls' }
        team_abbr { 'col' }
        user_region { 'ny' }
        region { 'ny' }
        user_count { 1 }
        notification_hour { 6 }
        notification_minute { 0 }
      end

      after(:create) do |promotion, evaluator|
        league = League.find_by(short_name: evaluator.league_abbr) || create(:league, short_name: evaluator.league_abbr)
        Team.find_by(
          short_name: evaluator.team_abbr,
          league: League.find_by(short_name: evaluator.league_abbr)
        ) || create(:team, short_name: evaluator.team_abbr, region: evaluator.region, league:, promotions: [promotion])

        create_list(
          :user,
          evaluator.user_count,
          :with_contact_methods,
          region: evaluator.region,
          notification_hour: evaluator.notification_hour,
          notification_minute: evaluator.notification_minute
        )
        promotion.reload
      end
    end
  end
end
