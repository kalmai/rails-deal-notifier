# frozen_string_literal: true

require 'rest-client'

module Mls
  class Client
    include BaseClient

    BASE_URL = 'https://sportapi.mlssoccer.com/api'

    def initialize(args: {}) = @args = args

    def schedule_cache = games_for_today

    def results_cache = results_for_yesterday
    # GameResult = Struct.new(:won?, :goals, :away?, :opponent, :utc_start_time, keyword_init: true) do
    #   def initialize(*)
    #     super
    #     self.utc_start_time = utc_start_time
    #   end
    # end
    # Goal = Struct.new(:period, :time, keyword_init: true)
    # TodayGame = Struct.new(:away?, :team_abbrev, :utc_start_time, keyword_init: true)
    # attrs:
    # GAME utc_start_time, team, opponent, goals, home_game (true, false), won (true, false)
    # GOAL period, score_time

    def store_games
      data = week_ago_week_from_now_data
      game_data = fetch_game_data(data)
      build_games(game_data)
    end

    def build_games(data)
      data.each do |datum|
        home_team = find_team_record(short_name: datum.dig('home', 'abbreviation').downcase)
        away_team = find_team_record(short_name: datum.dig('away', 'abbreviation').downcase)
        home_goals = { team: home_team, goals: datum.dig('goals', home_team.short_name) }
        away_goals = { team: away_team, goals: datum.dig('goals', away_team.short_name) }
        game = Game.create!(
          utc_start_time: Time.parse(datum['matchDate']),
          league: home_team.league, home_team:, away_team:
        )
        [home_goals, away_goals].each { create_goals_for(game:, data: _1) }
      end
    end

    def create_goals_for(game:, data:)
      data[:goals].each { |goals| Goal.create!(game:, team: data[:team], **goals) }
    end

    def find_team_record(short_name:)
      Team.joins(:league).where(teams: { short_name: }, leagues: { short_name: 'mls' }).first
    end

    def fetch_game_data(data)
      opta_ids = data.map do |datum|
        datum['optaId'] if Time.parse(datum['matchDate']).between?(2.days.ago, Time.current)
      end.compact

      opta_ids.map do |opta_id|
        raw_response = RestClient.get("#{BASE_URL}/matches/#{opta_id}")
        JSON.parse(raw_response).merge!('goals' => goals_for(game_id: opta_id))
      end
    end

    def week_ago_week_from_now_data
      last_week_str = 2.day.ago.strftime('%Y-%m-%d') # TODO: change this back to week from day after figuring out
      next_week_str = 2.day.from_now.strftime('%Y-%m-%d')
      raw_response = RestClient.get(
        "#{BASE_URL}/matches?culture=en-us&dateFrom=#{last_week_str}&dateTo=#{next_week_str}"
      )
      data = JSON.parse(raw_response)
    end

    private

    def results_for_yesterday
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
        victory_hash = victory_hash(datum)
        start_time = Time.parse(datum['matchDate'])
        result.merge!(build_goal_results(home_abbrev, away_abbrev, team_goals, victory_hash, start_time))
      end
    end

    def build_goal_results(home_team, away_team, team_goals, victory_hash, utc_start_time)
      {
        home_team => BaseClient::GameResult.new(away?: false, goals: team_goals[home_team], won?: victory_hash[:home],
                                                opponent: away_team, utc_start_time:),
        away_team => BaseClient::GameResult.new(away?: true, goals: team_goals[away_team], won?: victory_hash[:away],
                                                opponent: home_team, utc_start_time:)
      }.transform_keys(&:downcase)
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
        team_abbr = goal_data.dig('club', 'abbreviation').downcase
        goal = {
          'period' => goal_data['period'] == 'FirstHalf' ? 1 : 2,
          'utc_scored_at' => Time.at(goal_data['timestamp'] / 1000).utc
        }
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
  end
end
