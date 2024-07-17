# frozen_string_literal: true
# typed: true

class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :promotion
end
