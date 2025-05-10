# frozen_string_literal: true

FactoryBot.define do
  factory :event do
    period { 1 }
    utc_occurred_at { Time.current }
    event_type { 'goal' }
    slug { SecureRandom.uuid } # data should be cbj_1746845447 not uuids

    game
    team
  end
end
