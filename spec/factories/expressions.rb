# frozen_string_literal: true

FactoryBot.define do
  factory :expression do
    left { '1' }
    operand { '>' }
    right { '0' }
  end
end
