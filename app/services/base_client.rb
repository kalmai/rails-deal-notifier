# frozen_string_literal: true

require 'rest-client'

module BaseClient
  GameResult = Struct.new(:won?, :goals, :away?, :opponent, :utc_start_time, keyword_init: true) do
    def initialize(*)
      super
      self.utc_start_time = utc_start_time
    end
  end
  Goal = Struct.new(:period, :time, keyword_init: true)
  TodayGame = Struct.new(:away?, :team_abbrev, :utc_start_time, keyword_init: true)

  # perhaps adding a bulk call would be useful?
  # example output would be like: { won?: true, playing?: false } ({method: (method.eval)})
  def call(method) = send(method)

  def results_cache = raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"

  def schedule_cache = raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"

  private

  ### results_cache dependents
  def scored_in?
    return false unless played? && results_cache[@args[:short_name]].try(:goals).present?

    results_cache[@args[:short_name]].goals&.any? { _1.period == @args[:period].to_i }
  end

  def first_goal?
    return false unless played?

    defender = results_cache[@args[:short_name]]
    opponent = results_cache[defender.opponent.downcase]
    return false if defender.goals.empty?

    scored_first_goal?(defender, opponent)
  end

  def played?
    Time.use_zone(@args[:timezone]) do
      results_cache[@args[:short_name]]&.utc_start_time&.in_time_zone(@args[:timezone])&.yesterday?
    end || false
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

  def won? = played? && results_cache[@args[:short_name]].try(:won?) == true

  def goal_count_equal_or_above?
    return false unless played?

    results_cache[@args[:short_name]].goals.size >= @args[:goals_count]
  end

  def was_home? = played? && results_cache[@args[:short_name]].try(:away?) == false
  def was_away? = played? && results_cache[@args[:short_name]].try(:away?) == true
  ### results_cache dependents

  ### schedule_cache dependents
  def playing_today_at
    Time.use_zone(@args[:timezone]) do
      schedule_cache.find do |game|
        game.team_abbrev == @args[:short_name] && game.utc_start_time.in_time_zone(@args[:timezone]).today?
      end&.utc_start_time
    end
  end

  def future_home_game? = schedule_cache.find { |game| game.team_abbrev == @args[:short_name] }.try(:away?) == false
  def future_away_game? = schedule_cache.find { |game| game.team_abbrev == @args[:short_name] }.try(:away?) == true
  ### schedule_cache dependents
end
