# frozen_string_literal: true

class Game < ApplicationRecord
  validates :utc_start_time, presence: true

  belongs_to :away_team, class_name: 'Team'
  belongs_to :home_team, class_name: 'Team'
  belongs_to :league

  has_many :goals, -> { order('utc_scored_at') }

  def teams
    @teams ||= [away_team, home_team]
  end

  def team(short_name:)
    teams.find { |t| t.short_name.eql?(short_name) }
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
end
