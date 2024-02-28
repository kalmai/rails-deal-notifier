# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    postal { '15105' }
    region { 'pennsylvania' }
    country { 'us' }
    timezone { 'America/New_York' }
  end
end
