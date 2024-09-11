# frozen_string_literal: true

require 'rest-client'

module Mls
  class Client
    include BaseClient

    BASE_URL = 'https://sportapi.mlssoccer.com/api'

    def initialize(args:) = @args = args

    def schedule_cache = games_for_today

    def results_cache = results_for_yesterday

    private

    def results_for_yesterday
      return writen_empty_hash(cache_location: "#{self.class.module_parent}_yesterday") unless should_check_api?

      results = Rails.cache.read("#{self.class.module_parent}_yesterday")
      return results unless results.nil?

      league_results
    end

    def league_results
      result_hash = build_result_hash(aggregate_match_data)
      Rails.cache.write("#{self.class.module_parent}_yesterday", result_hash, expires_at: Time.now.end_of_day + 3.hours)
      result_hash
    end

    def build_result_hash(data)
      data.each_with_object({}) do |datum, result|
        home_abbrev = datum.dig('home', 'abbreviation')
        away_abbrev = datum.dig('away', 'abbreviation')
        team_goals = datum['goals']
        home_win = home_victory?(datum)
        start_time = Time.parse(datum['matchDate'])
        result.merge!(build_goal_results(home_abbrev, away_abbrev, team_goals, home_win, start_time))
      end
    end

    def build_goal_results(home_team, away_team, team_goals, home_win, utc_start_time)
      {
        home_team => BaseClient::GameResult.new(away?: false, goals: team_goals[home_team], won?: home_win,
                                                opponent: away_team, utc_start_time:),
        away_team => BaseClient::GameResult.new(away?: true, goals: team_goals[away_team], won?: !home_win,
                                                opponent: home_team, utc_start_time:)
      }.transform_keys(&:downcase)
    end

    def home_victory?(data)
      (data['homeScore'] <=> data['awayScore']) == 1
    end

    def aggregate_match_data
      data = schedule_and_results
      opta_ids = data.map do |datum|
        datum['optaId'] if Time.parse(datum['matchDate']).between?(2.days.ago, Time.current)
      end.compact

      opta_ids.map do |opta_id|
        raw_response = RestClient.get("#{BASE_URL}/matches/#{opta_id}")
        JSON.parse(raw_response).merge!('goals' => goals_for(game_id: opta_id))
      end
    end

    def goals_for(game_id:)
      get_goal_data(game_id).each_with_object(Hash.new { |h, k| h[k] = [] }) do |goal_data, hsh|
        team_abbr = goal_data.dig('club', 'abbreviation')
        goal = BaseClient::Goal.new(
          period: goal_data['period'] == 'FirstHalf' ? 1 : 2, time: Time.at(goal_data['timestamp'] / 1000).utc
        )
        hsh[team_abbr] = hsh[team_abbr].push(goal)
      end
    end

    def get_goal_data(game_id)
      raw_response = RestClient.get("https://stats-api.mlssoccer.com/v1/goals?&match_game_id=#{game_id}&order_by=goal_minute&include=club")
      JSON.parse(raw_response)
    end

    def schedule_and_results
      data = Rails.cache.read("#{self.class.module_parent}_schedule_and_results")
      return data unless data.nil?

      fetch_schedule_and_result_data
    end

    def fetch_schedule_and_result_data
      last_week_str = 1.week.ago.strftime('%Y-%m-%d')
      next_week_str = 1.week.from_now.strftime('%Y-%m-%d')
      raw_response = RestClient.get(
        "#{BASE_URL}/matches?culture=en-us&dateFrom=#{last_week_str}&dateTo=#{next_week_str}"
      )
      data = JSON.parse(raw_response)
      Rails.cache.write("#{self.class.module_parent}_schedule_and_results", data, expires_at: Time.now.end_of_day)
      data
    end

    def league_schedule_today
      return writen_empty_hash(cache_location: "#{self.class.module_parent}_today") unless should_check_api?

      data = schedule_and_results
      today_games = build_today_games(data)
      Rails.cache.write("#{self.class.module_parent}_today", today_games, expires_at: Time.now.end_of_day)
      today_games
    end

    def games_for_today
      results = Rails.cache.read("#{self.class.module_parent}_today")
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

    def should_check_api?
      League.find_by(short_name: self.class.module_parent.to_s.downcase).season_range.include?(Time.zone.now)
    end

    def writen_empty_hash(cache_location:)
      Rails.cache.write(cache_location, {}, expires_at: Time.now.end_of_day)
      {}
    end
  end
end
