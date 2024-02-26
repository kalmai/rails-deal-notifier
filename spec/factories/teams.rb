# frozen_string_literal: true

FactoryBot.define do
  factory :team do
    league { 'nhl' }
    full_name { 'columbus blue jackets' }
    short_name { 'cbj' }
  end
end
