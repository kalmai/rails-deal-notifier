# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    transient do
      contact_methods_count { 1 }
    end

    postal { '10001' }
    region { 'ny' }
    country { 'us' }
    timezone { 'America/New_York' }

    trait :with_contact_methods do
      after(:create) do |user, evaluator|
        create_list(:contact_method, evaluator.contact_methods_count, user:)
      end
    end
  end
end
