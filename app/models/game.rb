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

  def played?(timezone:)
    @played ||= Time.use_zone(timezone) { utc_start_time.in_time_zone(timezone)&.yesterday? } || false
  end

  def scored_in?(timezone:, period:)
    return false unless played?(timezone:) && goals.present?

    goals.any? { _1.period == period.to_i }
  end

  def first_goal?
    return false unless played?

    defender = results_cache[@args[:short_name]]
    opponent = results_cache[defender.opponent.downcase]
    return false if defender.goals.empty?

    scored_first_goal?(defender, opponent)
  end

  def scored_first_goal?(defender, attacker)
    defender_first_goal = defender.goals.first
    attacker_first_goal = attacker.goals.first
    return true if defender_first_goal.period < attacker_first_goal.period
    return false if defender_first_goal.period > attacker_first_goal.period

    Time.parse("00:#{defender_first_goal.time}") < Time.parse("00:#{attacker_first_goal.time}")
  end

  def perfect_defence?
    return false unless played?

    defender = results_cache[@args[:short_name]]
    opponent = results_cache[defender.opponent.downcase]
    opponent.goals.empty?
  end

  def goal_count_equal_or_above?
    return false unless played?

    results_cache[@args[:short_name]].goals.size >= @args[:goals_count]
  end

  def home?
    played? && results_cache[@args[:short_name]].try(:away?) == false
  end

  def away?
    played? && results_cache[@args[:short_name]].try(:away?)
  end

  def won?
    played? && results_cache[@args[:short_name]].try(:won?) == true
  end

  class << self
    def most_recent_game(team_id:)
      find_games_for(team_id:).order(:utc_start_time).reverse_order.where(has_consumed_results: true).first
    end

    def find_games_for(team_id:)
      where(home_team_id: team_id).or(where(away_team_id: team_id))
    end
  end
end
