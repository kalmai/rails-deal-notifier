# frozen_string_literal: true

FactoryBot.define do
  factory :goal do
    period { 1 }
    utc_scored_at { Time.current }

    game
    team
  end
end
