# frozen_string_literal: true

class Goal < ApplicationRecord
  validates :period, :utc_scored_at, presence: true

  belongs_to :game
  belongs_to :team
end
