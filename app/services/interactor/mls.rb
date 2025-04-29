# frozen_string_literal: true

require 'rest-client'

module Interactor
  class Mls
    BASE_URL = 'https://stats-api.mlssoccer.com'

    class << self
      def store_games
        build_games(week_ago_week_from_now_data)
      end

      def update_games
        Game.where(has_consumed_results: false, league_id: League.find_by(short_name: 'mls')).each do |game|
          data = match_data(match_id: game.league_specifics['match_id'])
          next unless data['data_status'] == 'postmatch'

          game.update(has_consumed_results: true)
          [game.home_team, game.away_team].each do |team|
            create_goals_for(game:, data: { team:, goals: data.dig('goals', team.short_name) })
          end
        end
      end

      private

      def build_games(data)
        data.each do |datum|
          home_team = find_team_record(short_name: datum['home_team_three_letter_code'].downcase)
          away_team = find_team_record(short_name: datum['away_team_three_letter_code'].downcase)
          utc_start_time = Time.parse(datum['start_date'])
          slug = "#{home_team.short_name}vs#{away_team.short_name}-#{utc_start_time.strftime('%m-%d-%Y')}"

          next unless Game.find_by(slug:).blank?

          Game.create! \
            away_team:, home_team:, utc_start_time:, slug:,
            league_specifics: { match_id: datum['match_id'] }, league: home_team.league
        end
      end

      def get_goal_data(match_id)
        begin
          raw_response = RestClient.get("#{BASE_URL}/matches/#{match_id}/key_events?per_page=1000")
        rescue RestClient::ExceptionWithResponse => e
          e.response
        end
        JSON.parse(raw_response || '{}')
      end

      def create_goals_for(game:, data:)
        data[:goals].each { |goals| Goal.create!(game:, team: data[:team], **goals) }
      end

      def find_team_record(short_name:)
        Team.joins(:league).where(teams: { short_name: }, leagues: { short_name: 'mls' }).first
      end

      def week_ago_week_from_now_data
        last_week_str = 7.day.ago.strftime('%Y-%m-%d')
        today = Time.now.strftime('%Y-%m-%d')
        next_week_str = 7.day.from_now.strftime('%Y-%m-%d')
        last_week_resp = RestClient.get(
          "#{BASE_URL}/matches/seasons/MLS-SEA-0001K9?match_date[gte]=#{last_week_str}&match_date[lte]=#{today}&competition_id=MLS-COM-000001"
        )
        next_week_resp = RestClient.get(
          "#{BASE_URL}/matches/seasons/MLS-SEA-0001K9?match_date[gte]=#{today}&match_date[lte]=#{next_week_str}&competition_id=MLS-COM-000001"
        )

        JSON.parse(last_week_resp)['schedule'].concat(JSON.parse(next_week_resp)['schedule']).uniq
      end

      def match_data(match_id:)
        data = get_goal_data(match_id)
        return {} if data.empty?

        goal_events = data['events']&.select { _1['sub_type'].eql?('goals') }
        event_data = goal_events.map { _1['event'] }
        goal_hash = event_data.each_with_object(Hash.new { |h, k| h[k] = [] }) do |goal_data, hsh|
          team_abbr = goal_data['three_letter_code'].downcase
          goal = {
            'period' => goal_data['game_section'] == 'firstHalf' ? 1 : 2,
            'utc_scored_at' => Time.parse(goal_data['event_time'])
          }
          hsh[team_abbr] = hsh[team_abbr].push(goal)
        end

        data['match_info'].merge('goals' => goal_hash)
      end
    end
  end
end
