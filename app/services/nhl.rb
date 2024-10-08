# frozen_string_literal: true

require 'rest-client'

module Nhl
  class Client
    include BaseClient

    BASE_URL = 'https://api-web.nhle.com'

    def initialize(args:) = @args = args

    def schedule_cache = games_for_today

    def results_cache = results_for_yesterday

    private

    def results_for_yesterday
      results = Rails.cache.read("#{self.class.module_parent}_yesterday")
      return results unless results.nil?

      league_results
    end

    def league_results
      result_hash = build_result_hash(results_from_two_days)
      Rails.cache.write("#{self.class.module_parent}_yesterday", result_hash, expires_at: Time.now.end_of_day + 3.hours)
      result_hash
    end

    def results_from_two_days
      [2, 1].map do |days_ago|
        raw_response = RestClient.get("#{BASE_URL}/v1/score/#{days_ago.days.ago.strftime('%Y-%m-%d')}")
        JSON.parse(raw_response)['games']
      end.flatten!
    end

    def build_result_hash(data)
      data.each_with_object({}) do |datum, result|
        home_abbrev = datum.dig('homeTeam', 'abbrev')
        away_abbrev = datum.dig('awayTeam', 'abbrev')
        team_goals = build_goals(datum['goals'])
        victory_hash = victory_hash(datum)
        start_time = Time.parse(datum['startTimeUTC'])

        result.merge!(build_goal_results(home_abbrev, away_abbrev, team_goals, victory_hash, start_time))
      end
    end

    def build_goal_results(home_team, away_team, team_goals, victory_hash, utc_start_time)
      {
        home_team => BaseClient::GameResult.new(
          away?: false, goals: team_goals[home_team], won?: victory_hash[:home],
          opponent: away_team, utc_start_time:
        ),
        away_team => BaseClient::GameResult.new(
          away?: true, goals: team_goals[away_team], won?: victory_hash[:away],
          opponent: home_team, utc_start_time:
        )
      }.transform_keys(&:downcase)
    end

    def build_goals(goals)
      goals.each.with_object({}) do |goal, goal_results|
        if goal_results.keys.include?(goal['teamAbbrev'])
          goal_results[goal['teamAbbrev']].push(BaseClient::Goal.new(period: goal['period'],
                                                                     time: goal['timeInPeriod']))
        else
          goal_results[goal['teamAbbrev']] =
            [BaseClient::Goal.new(period: goal['period'], time: goal['timeInPeriod'])]
        end
      end
    end

    def victory_hash(data)
      {
        home: (data.dig('homeTeam', 'score') <=> data.dig('awayTeam', 'score')) == 1,
        away: (data.dig('awayTeam', 'score') <=> data.dig('homeTeam', 'score')) == 1
      }
    end

    def games_for_today
      results = Rails.cache.read("#{self.class.module_parent}_today")
      return results unless results.nil?

      league_schedule_today
    end

    def league_schedule_today
      data = nhl_schedule
      games = data['gameWeek'].select { |hsh| hsh['date'] == Time.zone.now.strftime('%Y-%m-%d') }.first['games']
      games_today = build_today_games(games)
      Rails.cache.write("#{self.class.module_parent}_today", games_today, expires_at: Time.now.end_of_day)
      games_today
    end

    def nhl_schedule
      raw_response = RestClient.get("#{BASE_URL}/v1/schedule/now")
      JSON.parse(raw_response.body)
    end

    def build_today_games(games)
      games.each_with_object([]) do |game, arr|
        time = Time.parse(game['startTimeUTC'])
        arr << BaseClient::TodayGame.new(away?: false, team_abbrev: game.dig('homeTeam', 'abbrev').downcase,
                                         utc_start_time: time)
        arr << BaseClient::TodayGame.new(away?: true, team_abbrev: game.dig('awayTeam', 'abbrev').downcase,
                                         utc_start_time: time)
      end
    end
  end
end
