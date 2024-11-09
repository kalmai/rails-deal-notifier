# frozen_string_literal: true

class Game < ApplicationRecord
  validates :utc_start_time, presence: true
  validates :slug, uniqueness: true

  belongs_to :league
  belongs_to :home_team, class_name: 'Team'
  belongs_to :away_team, class_name: 'Team'
  has_many :goals, -> { order('utc_scored_at') }, dependent: :destroy

  def home_goals
    goals.where(team_id: home_team.id)
  end

  def away_goals
    goals.where(team_id: away_team.id)
  end

  class << self
    def next_game(team_id:)
      find_games_for(team_id:).order(:utc_start_time).where(has_consumed_results: false).first
    end

    def most_recent_game(team_id:)
      find_games_for(team_id:).order(:utc_start_time).reverse_order.where(has_consumed_results: true).first
    end

    def find_games_for(team_id:)
      where(home_team_id: team_id).or(where(away_team_id: team_id))
    end
  end
end
