# frozen_string_literal: true

require 'rest-client'

module Mls
  class Client < BaseClient
    class << self
      BASE_URL = 'https://sportapi.mlssoccer.com/api'

      def schedule_cache
        # At some point, we can probably extract out the builder methods to a building library?
        games_for_today
      end

      def results_cache
        results_for_yesterday
      end

      private

      # the below request returns all the teams in MLS, should be useful when creating teams via seeding?
      # raw_response = RestClient.get("#{BASE_URL}/standings/live?isLive=true&seasonId=2024&competitionId=98")
      def results_for_yesterday
        results = Rails.cache.read("#{module_parent}_yesterday")
        return results if results.present?

        league_results
      end

      def league_results
        result_hash = build_result_hash(aggregate_match_data)
        Rails.cache.write("#{module_parent}_yesterday", result_hash, expires_at: Time.now.end_of_day + 3.hours)
        result_hash
      end

      def build_result_hash(data)
        data.each_with_object({}) do |datum, result|
          home_abbrev = datum.dig('home', 'abbreviation')
          away_abbrev = datum.dig('away', 'abbreviation')
          team_goals = { "#{home_abbrev}": datum['homeScore'], "#{away_abbrev}": datum['awayScore'] }
                       .transform_values { Array.new(_1) { BaseClient::Goal.new } }.stringify_keys
          home_win = home_victory?(datum)

          result.merge!(build_goal_results(home_abbrev, away_abbrev, team_goals, home_win))
        end
      end

      def build_goal_results(home_team, away_team, team_goals, home_win)
        {
          home_team => BaseClient::GameResult.new(away?: false, goals: team_goals[home_team], won?: home_win,
                                                  opponent: away_team),
          away_team => BaseClient::GameResult.new(away?: true, goals: team_goals[away_team], won?: !home_win,
                                                  opponent: home_team)
        }.transform_keys(&:downcase)
      end

      def home_victory?(data)
        (data['homeScore'] <=> data['awayScore']) == 1
      end

      def aggregate_match_data
        data = schedule_and_results
        # https://sportapi.mlssoccer.com/api/matches/<optaId>? which is available in data
        _opta_ids = data.map do |datum|
          date = Time.parse(datum['matchDate'])
          datum['optaId'] if date > Time.zone.now.yesterday && date < Time.zone.now
        end.compact
        # aggregated_data = aggregate_match_data(opta_ids) this is what we actually wanna use
        test_opt_ids = [2_415_025, 2_415_026, 2_415_027, 2_415_028, 2_415_029, 2_415_030, 2_415_031, 2_415_165]
        # opta_ids.map do |opta_id|
        test_opt_ids.map do |opta_id|
          raw_response = RestClient.get("#{BASE_URL}/matches/#{opta_id}")
          JSON.parse(raw_response)
        end
      end

      def schedule_and_results
        data = Rails.cache.read("#{module_parent}_schedule_and_results")
        return data if data.present?

        fetch_schedule_and_result_data
      end

      def fetch_schedule_and_result_data
        last_week_str = 1.week.ago.strftime('%Y-%m-%d')
        next_week_str = 1.week.from_now.strftime('%Y-%m-%d')
        raw_response = RestClient.get(
          "#{BASE_URL}/matches?culture=en-us&dateFrom=#{last_week_str}&dateTo=#{next_week_str}"
        )
        data = JSON.parse(raw_response)
        Rails.cache.write("#{module_parent}_schedule_and_results", data, expires_at: Time.now.end_of_day)
        data
      end

      def league_schedule_today
        data = schedule_and_results
        today_games = build_today_games(data)
        Rails.cache.write("#{module_parent}_today", today_games, expires_at: Time.now.end_of_day)
        today_games
      end

      def games_for_today
        results = Rails.cache.read("#{module_parent}_today")
        return results if results.present?

        league_schedule_today
      end

      def build_today_games(data)
        data.each_with_object([]) do |game, arr|
          time = Time.parse(game['matchDate'])
          arr << BaseClient::TodayGame.new(away?: false, team_abbrev: game.dig('home', 'abbreviation').downcase,
                                           utc_start_time: time)
          arr << BaseClient::TodayGame.new(away?: true, team_abbrev: game.dig('away', 'abbreviation').downcase,
                                           utc_start_time: time)
        end
      end
    end
  end
end
