# frozen_string_literal: true

class Event < ApplicationRecord
  enum :event_type, %i[goal]
  validates :slug, :event_type, :period, :utc_occurred_at, presence: true

  belongs_to :game
  belongs_to :team
end
