# frozen_string_literal: true

FactoryBot.define do
  factory :game do
    transient do
      league_short_name { 'mls' }
      home_short_name { 'atl' }
      away_short_name { 'mtl' }
    end

    utc_start_time { Time.parse('2024-10-02T23:30:00.0000000Z') }
    league_specifics { { opta_id: '2415301' } }
    has_consumed_results { false }
    slug { "#{home_short_name}vs#{away_short_name}-#{utc_start_time.strftime('%m-%d-%Y')}" }

    league { create(:league, short_name: league_short_name) }
    home_team { create(:team, league:, short_name: home_short_name) }
    away_team { create(:team, league:, short_name: away_short_name) }
  end
end
