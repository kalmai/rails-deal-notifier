# frozen_string_literal: true

require 'rest-client'

module Nhl
  class Client < BaseClient
    class << self
      BASE_URL = 'https://api-web.nhle.com'

      def schedule_cache
        games_for_today
      end

      def results_cache
        results_for_yesterday
      end

      private

      def results_for_yesterday
        results = Rails.cache.read("#{module_parent}_yesterday")
        return results if results.present?

        league_results
        Rails.cache.read("#{module_parent}_yesterday")
      end

      def league_results
        raw_response = RestClient.get("#{BASE_URL}/v1/score/#{Time.now.yesterday.strftime('%Y-%m-%d')}")
        result_hash = build_result_hash(JSON.parse(raw_response)['games'])
        Rails.cache.write("#{module_parent}_yesterday", result_hash, expires_at: Time.now.end_of_day + 3.hours)
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
          home_team => BaseClient::GameResult.new(away?: false, goals: team_goals[home_team], won?: home_win, opponent: away_team),
          away_team => BaseClient::GameResult.new(away?: true, goals: team_goals[away_team], won?: !home_win, opponent: home_team)
        }.transform_keys(&:downcase)
      end

      def build_goals(goals)
        goals.each.with_object({}) do |goal, goal_results|
          if goal_results.keys.include?(goal['teamAbbrev'])
            goal_results[goal['teamAbbrev']].push(BaseClient::Goal.new(period: goal['period'], time: goal['timeInPeriod']))
          else
            goal_results[goal['teamAbbrev']] = [BaseClient::Goal.new(period: goal['period'], time: goal['timeInPeriod'])]
          end
        end
      end

      def home_victory?(data)
        (data.dig('homeTeam', 'score') <=> data.dig('awayTeam', 'score')) == 1
      end

      def games_for_today
        results = Rails.cache.read("#{module_parent}_today")
        return results if results.present?

        league_schedule_today
      end

      def league_schedule_today
        raw_response = RestClient.get("#{BASE_URL}/v1/schedule/now")
        data = JSON.parse(raw_response.body)
        games = data['gameWeek'].select { |hsh| hsh['date'] == Time.zone.now.strftime('%Y-%m-%d') }.first['games']
        games_today = build_today_games(games)
        Rails.cache.write("#{module_parent}_today", games_today, expires_at: Time.now.end_of_day)
        games_today
      end

      def build_today_games(games)
        games.each_with_object([]) do |game, arr|
          time = Time.parse(game['startTimeUTC'])
          arr << BaseClient::TodayGame.new(away?: false, team_abbrev: game.dig('homeTeam', 'abbrev').downcase, utc_start_time: time)
          arr << BaseClient::TodayGame.new(away?: true, team_abbrev: game.dig('awayTeam', 'abbrev').downcase, utc_start_time: time)
        end
      end
    end
  end
end
