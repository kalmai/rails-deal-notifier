# frozen_string_literal: true

class Game < ApplicationRecord
  validates :utc_start_time, presence: true
  validates :slug, uniqueness: true

  belongs_to :league
  belongs_to :home_team, class_name: 'Team'
  belongs_to :away_team, class_name: 'Team'
  has_many :events, -> { order('utc_occurred_at') }, dependent: :destroy

  def home_goals
    events.where(team_id: home_team.id)
  end

  def away_goals
    events.where(team_id: away_team.id)
  end

  def teams
    [home_team, away_team]
  end

  class << self
    def next_game(team_id:)
      find_games_for(team_id:).order(:utc_start_time).where(finalized: false).first
    end

    def most_recent_game(team_id:)
      find_games_for(team_id:).order(:utc_start_time).reverse_order.where(finalized: true).first
    end

    def find_games_for(team_id:)
      where(home_team_id: team_id).or(where(away_team_id: team_id))
    end
  end
end
