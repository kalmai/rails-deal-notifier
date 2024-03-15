# frozen_string_literal: true

require 'rest-client'

GameResult = Struct.new(:won?, :goals, :away?, :opponent, keyword_init: true)
Goal = Struct.new(:period, :time, keyword_init: true)

module Nhl
  class Client
    BASE_URL = 'https://api-web.nhle.com'

    class << self
      def call(method, args)
        return false unless played?(args[:short_name])

        send(method, args)
      end

      private

      def won?(args)
        results_for_yesterday[args[:short_name]].won?
      end

      def scored_in?(args)
        return false unless results_for_yesterday[args[:short_name]].goals&.present?

        results_for_yesterday[args[:short_name]].goals&.any? { _1.period == args[:period].to_i }
      end

      def first_goal?(args)
        defender = results_for_yesterday[args[:short_name]]
        opponent = results_for_yesterday[defender.opponent.downcase]
        return false if defender.goals.empty?

        scored_first_goal?(defender, opponent)
      end

      def played?(short_name)
        short_name.in?(results_for_yesterday.keys)
      end

      def scored_first_goal?(defender, attacker)
        defender_first_goal = defender.goals.first
        attacker_first_goal = attacker.goals.first
        return true if defender_first_goal.period < attacker_first_goal.period
        return false if defender_first_goal.period > attacker_first_goal.period

        Time.parse("00:#{defender_first_goal.time}") < Time.parse("00:#{attacker_first_goal.time}")
      end

      def results_for_yesterday
        results = Rails.cache.read(:nhl_yesterday)
        return results if results.present?

        nhl_results
        Rails.cache.read(:nhl_yesterday)
      end

      def nhl_results
        raw_response = RestClient.get("#{BASE_URL}/v1/score/#{Time.now.yesterday.strftime('%Y-%m-%d')}")
        result_hash = build_result_hash(JSON.parse(raw_response)['games'])
        Rails.cache.write(:nhl_yesterday, result_hash, expires_at: Time.now.end_of_day + 3.hours)
      end

      def build_result_hash(data)
        data.each_with_object({}) do |datum, result|
          home_abbrev = datum.dig('homeTeam', 'abbrev')
          away_abbrev = datum.dig('awayTeam', 'abbrev')
          team_goals = build_goals(datum['goals'])
          home_win = home_victory?(datum)

          result.merge!(build_goal_results(home_abbrev, away_abbrev, team_goals, home_win))
        end
      end

      def build_goal_results(home_team, away_team, team_goals, home_win)
        {
          home_team => GameResult.new(away?: false, goals: team_goals[home_team], won?: home_win, opponent: away_team),
          away_team => GameResult.new(away?: true, goals: team_goals[away_team], won?: !home_win, opponent: home_team)
        }.transform_keys(&:downcase)
      end

      def build_goals(goals)
        goal_results = {}
        goals.each do |goal|
          if goal_results.keys.include?(goal['teamAbbrev'])
            goal_results[goal['teamAbbrev']].push(Goal.new(period: goal['period'], time: goal['timeInPeriod']))
          else
            goal_results[goal['teamAbbrev']] = [Goal.new(period: goal['period'], time: goal['timeInPeriod'])]
          end
        end
        goal_results
      end

      def home_victory?(data)
        (data.dig('homeTeam', 'score') <=> data.dig('awayTeam', 'score')) == 1
      end
    end
  end
end
