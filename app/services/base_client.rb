# frozen_string_literal: true

require 'rest-client'

class BaseClient
  GameResult = Struct.new(:won?, :goals, :away?, :opponent, keyword_init: true)
  Goal = Struct.new(:period, :time, keyword_init: true)
  TodayGame = Struct.new(:away?, :team_abbrev, :utc_start_time, keyword_init: true)

  def schedule_cache; end
  def results_cache; end

  class << self
    # perhaps adding a bulk call would be useful?
    # example output would be like: { won?: true, playing?: false } ({method: (method.eval)})
    def call(method, args)
      send(method, args)
    end

    private

    def playing_today_at(args)
      schedule_cache.map do |game|
        next unless game.team_abbrev == args[:short_name]
        next unless game.utc_start_time.in_time_zone(args[:timezone]).today?

        game
      end&.compact&.first&.utc_start_time
    end

    def won?(args)
      played?(args) && results_cache[args[:short_name]].try(:won?) == true
    end

    def scored_in?(args)
      return false unless played?(args) && results_cache[args[:short_name]].try(:goals).present?

      results_cache[args[:short_name]].goals&.any? { _1.period == args[:period].to_i }
    end

    def first_goal?(args)
      return false unless played?(args)

      defender = results_cache[args[:short_name]]
      opponent = results_cache[defender.opponent.downcase]
      return false if defender.goals.empty?

      scored_first_goal?(defender, opponent)
    end

    def played?(args)
      args[:short_name].in?(results_cache.keys)
    end

    def scored_first_goal?(defender, attacker)
      defender_first_goal = defender.goals.first
      attacker_first_goal = attacker.goals.first
      return true if defender_first_goal.period < attacker_first_goal.period
      return false if defender_first_goal.period > attacker_first_goal.period

      Time.parse("00:#{defender_first_goal.time}") < Time.parse("00:#{attacker_first_goal.time}")
    end
  end
end
