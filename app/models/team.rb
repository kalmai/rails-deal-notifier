# frozen_string_literal: true

class Team < ApplicationRecord
  validates :region, :country, :full_name, presence: true
  belongs_to :league
end
