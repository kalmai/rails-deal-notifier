# frozen_string_literal: true

require 'rest-client'

class BaseClient
  GameResult = Struct.new(:won?, :goals, :away?, :opponent, :utc_start_time, keyword_init: true) do
    def initialize(*)
      super
      self.utc_start_time = utc_start_time
    end
  end
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
      Time.use_zone(args[:timezone]) do
        schedule_cache.find do |game|
          game.team_abbrev == args[:short_name] && game.utc_start_time.in_time_zone(args[:timezone]).today?
        end&.utc_start_time || false
      end
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
      Time.use_zone(args[:timezone]) do
        results_cache[args[:short_name]]&.utc_start_time&.in_time_zone(args[:timezone])&.yesterday?
      end
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
