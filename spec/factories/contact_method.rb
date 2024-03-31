# frozen_string_literal: true

FactoryBot.define do
  factory :contact_method do
    contact_detail { Faker::Internet.email }
    contact_type { :email }
    enabled { true }

    user
  end
end
