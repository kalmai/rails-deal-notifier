# frozen_string_literal: true
# typed: true

class Team < ApplicationRecord
  validates :region, :country, :full_name, presence: true
  belongs_to :league
  has_many :promotions
end
