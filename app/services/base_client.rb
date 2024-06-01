# frozen_string_literal: true

require 'rest-client'

class BaseClient
  INVOKABLES = { played?: %w[won? scored_in? first_goal?], playing?: %w[playing_at] }.with_indifferent_access.freeze

  GameResult = Struct.new(:won?, :goals, :away?, :opponent, keyword_init: true)
  Goal = Struct.new(:period, :time, keyword_init: true)
  TodayGame = Struct.new(:away?, :team_abbrev, :utc_start_time, keyword_init: true)

  def schedule_cache; end
  def results_cache; end

  class << self
    # perhaps adding a bulk call would be useful?
    # example output would be like: { won?: true, playing?: false } ({method: (method.eval)})
    def call(method, args)
      return false unless ignore_invokation?(method, args)

      send(method, args)
    end

    private

    def ignore_invokation?(method, args)
      INVOKABLES.each do |guard_method, sent_method|
        return send(guard_method, args) if method.in?(sent_method)
      end
    end

    def playing_at(args)
      # return 1.hour.from_now # TODO: remove this line

      schedule_cache.find { |ele| ele.team_abbrev == args[:short_name] }.utc_start_time
    end

    def won?(args)
      results_cache[args[:short_name]].try(:won?) == true
    end

    def scored_in?(args)
      return false unless results_cache[args[:short_name]].try(:goals).present?

      results_cache[args[:short_name]].goals&.any? { _1.period == args[:period].to_i }
    end

    def first_goal?(args)
      defender = results_cache[args[:short_name]]
      opponent = results_cache[defender.opponent.downcase]
      return false if defender.goals.empty?

      scored_first_goal?(defender, opponent)
    end

    def played?(args)
      args[:short_name].in?(results_cache.keys)
    end

    def playing?(args)
      # return true # TODO: remove this line
      today_teams = schedule_cache.map { _1.team_abbrev if _1.utc_start_time.today? }.compact
      args[:short_name].in?(today_teams)
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
