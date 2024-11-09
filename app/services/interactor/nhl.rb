# frozen_string_literal: true

require 'rest-client'

module Interactor
  class Nhl
    BASE_URL = 'https://api-web.nhle.com'

    class << self
      def store_games
        build_games(week_ago_week_from_now_data)
      end

      def build_games(data)
        data.each do |datum|
          home_team = find_team_record(short_name: datum.dig('homeTeam', 'abbrev').downcase)
          away_team = find_team_record(short_name: datum.dig('awayTeam', 'abbrev').downcase)
          utc_start_time = Time.parse(datum['startTimeUTC'])
          slug = "#{home_team.short_name}vs#{away_team.short_name}-#{utc_start_time.strftime('%m-%d-%Y')}"
          next unless Game.find_by(slug:).blank?

          Game.create!(away_team:, home_team:, utc_start_time:, slug:, league: home_team.league)
        end
      end

      def update_games
        date_results = {}
        Game.where(has_consumed_results: false, league: League.find_by(short_name: 'nhl')).each do |game|
          date_results = upsert_results(results: date_results, on: game.utc_start_time)
          datum = find_datum(results: date_results, slug: game.slug, on: game.utc_start_time)
          next unless datum['gameOutcome'].present?

          game.update(has_consumed_results: true)
          [game.home_team, game.away_team].each { |team| create_goals_for(game:, team:, goal_data: datum) }
        end
      end

      private

      def create_goals_for(game:, team:, goal_data:)
        team_goals = goal_data['goals'].select { |goal| goal if goal['teamAbbrev'].downcase.eql?(team.short_name) }
        team_goals.each do |goal|
          Goal.create! \
            game:, team:, period: goal['period'],
            utc_scored_at: assumed_utc_score_time(game_start_time: game.utc_start_time, goal_data: goal)
        end
      end

      def assumed_utc_score_time(game_start_time:, goal_data:)
        minutes, seconds = goal_data['timeInPeriod'].split(':').map(&:to_i)
        game_start_time + (((goal_data['period'] - 1) * 20) + minutes).minutes + seconds.seconds
      end

      def find_datum(results:, slug:, on:)
        date = on.strftime('%Y-%m-%d')
        date_data = results[date]
        datum = date_data.find { |data| data['slug'].eql?(slug) }
        return datum unless datum.nil?

        find_datum(results: upsert_results(results:, on: on.yesterday), slug:, on: on.yesterday)
      end

      def upsert_results(results:, on:)
        date = on.strftime('%Y-%m-%d')
        results[date] = fetch_results(on: date) unless results.keys.include?(date)
        results
      end

      def week_ago_week_from_now_data
        last_week = fetch_week_of_game_data(from: 7.day.ago)
        next_week = fetch_week_of_game_data(from: Time.current)
        last_week.concat(next_week)
      end

      def fetch_results(on:)
        raw_response = RestClient.get("#{BASE_URL}/v1/score/#{on}")
        JSON.parse(raw_response)['games'].each do |datum|
          home_team = datum.dig('homeTeam', 'abbrev').downcase
          away_team = datum.dig('awayTeam', 'abbrev').downcase
          utc_start_time = Time.parse(datum['startTimeUTC'])
          slug = "#{home_team}vs#{away_team}-#{utc_start_time.strftime('%m-%d-%Y')}"
          datum.merge!('slug' => slug)
        end
      end

      def fetch_week_of_game_data(from:)
        raw_response = RestClient.get("#{BASE_URL}/v1/schedule/#{from.strftime('%Y-%m-%d')}")
        JSON.parse(raw_response)['gameWeek'].map { _1['games'] }.flatten
      end

      def find_team_record(short_name:)
        Team.joins(:league).where(teams: { short_name: }, leagues: { short_name: 'nhl' }).first
      end
    end
  end
end
