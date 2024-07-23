# frozen_string_literal: true

FactoryBot.define do
  factory :game do
    transient do
      home_goal_count { 1 }
    end
    utc_start_time { Time.current }

    league { create(:league) }
    home_team { create(:team, short_name: 'home') }
    away_team { create(:team) }
    goals { create_list(:goal, home_goal_count, game: instance, team: home_team) }
  end
end
