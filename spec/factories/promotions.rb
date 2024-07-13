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

    trait :cbj_moo_moo_carwash do
      company { 'Moo Moo Express Car Wash' }
      promo_type { 'free_gifts' }
      name { 'Moo Moo Express Car Wash 3rd Period Goal' }
      promo_code { nil }
      source_url { 'https://www.nhl.com/bluejackets/fans/gameday-central' }
      api_methods { %w[scored_in?] }
      api_parameters { { period: 3 } }
      timing_methods { %w[playing_at] }
      timing_parameters { { minutes_before: 60 } }
      team { association :team, short_name: 'cbj', region: 'ohio', league: create(:league, short_name: 'nhl') }
      # requirements do
      #   [
      #     'sign up on gameday', 'one hour before the start of the game',
      #     'or till end of game', 'sign up here: https://moomoocarwash.com/cbj/',
      #     'enter cellphone number'
      #   ]
      # end
    end

    trait :with_league_team_and_users do
      transient do
        league_abbr { 'mls' }
        team_abbr { 'col' }
        user_region { 'ny' }
        region { 'ny' }
        user_count { 1 }
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
          region: evaluator.region
        )
        promotion.reload
      end
    end
  end
end
