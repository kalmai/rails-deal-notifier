# frozen_string_literal: true

FactoryBot.define do
  factory :team do
    transient do
      team_name { Faker::Sports::Football.team.downcase }
    end

    league
    full_name { team_name }
    short_name { team_name.split.map(&:first).join }
    region { Faker::Address.state.downcase }
    country { 'us' }
  end
end
