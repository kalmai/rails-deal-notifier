# frozen_string_literal: true

require 'rest-client'

module Interactor
  class Mls
    BASE_URL = 'https://sportapi.mlssoccer.com/api'
    GOAL_DATA_URL = 'https://stats-api.mlssoccer.com/v1/goals'

    class << self
      def store_games
        build_games(week_ago_week_from_now_data)
      end

      def update_games
        Game.where(has_consumed_results: false, league_id: League.find_by(short_name: 'mls')).each do |game|
          data = aggregate_match_data(opta_id: game.league_specifics['opta_id'])
          next unless data['period'] == 'FullTime'

          game.update(has_consumed_results: true)
          [game.home_team, game.away_team].each do |team|
            create_goals_for(game:, data: { team:, goals: data.dig('goals', team.short_name) })
          end
        end
      end

      private

      def build_games(data)
        data.each do |datum|
          next unless Game.find_by(slug: datum['slug']).blank?

          home_team = find_team_record(short_name: datum.dig('home', 'abbreviation').downcase)
          away_team = find_team_record(short_name: datum.dig('away', 'abbreviation').downcase)
          Game.create! \
            away_team:, home_team:, utc_start_time: Time.parse(datum['matchDate']), slug: datum['slug'],
            league_specifics: { opta_id: datum['optaId'] }, league: home_team.league
        end
      end

      def aggregate_match_data(opta_id:)
        raw_response = RestClient.get("#{BASE_URL}/matches/#{opta_id}")
        JSON.parse(raw_response).merge!('goals' => goals_for(game_id: opta_id))
      end

      def get_goal_data(game_id)
        raw_response = RestClient.get("#{GOAL_DATA_URL}?&match_game_id=#{game_id}&order_by=goal_minute&include=club")
        JSON.parse(raw_response)
      end

      def create_goals_for(game:, data:)
        data[:goals].each { |goals| Goal.create!(game:, team: data[:team], **goals) }
      end

      def find_team_record(short_name:)
        Team.joins(:league).where(teams: { short_name: }, leagues: { short_name: 'mls' }).first
      end

      def week_ago_week_from_now_data
        last_week_str = 7.day.ago.strftime('%Y-%m-%d')
        next_week_str = 7.day.from_now.strftime('%Y-%m-%d')
        raw_response = RestClient.get(
          "#{BASE_URL}/matches?culture=en-us&dateFrom=#{last_week_str}&dateTo=#{next_week_str}"
        )
        JSON.parse(raw_response)
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
    end
  end
end
