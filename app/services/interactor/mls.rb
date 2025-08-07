# frozen_string_literal: true

require 'rest-client'

module Interactor
  class Mls
    BASE_URL = 'https://stats-api.mlssoccer.com/matches'

    class << self
      def store_games
        build_games(week_ago_week_from_now_data)
      end

      def update_games
        Game.where(finalized: false, league_id: League.find_by(short_name: 'mls')).each do |game|
          data = match_data(match_id: game.league_specifics['match_id'])

          game.update(finalized: true) if data['data_status'] == 'postmatch'
          [game.home_team, game.away_team].each do |team|
            create_goals_for(game:, data: { team:, events: data.dig('goals', team.short_name) })
          end
        end
      end

      private

      def build_games(data)
        data.each do |datum|
          game_attrs = game_attributes(datum)
          next unless Game.find_by(slug: game_attrs[:slug]).blank?

          Game.create!(
            **game_attrs, league_specifics: { match_id: datum['match_id'] }, league: game_attrs[:home_team]&.league
          )
        end
      end

      def game_attributes(datum)
        away_team = find_team_record(short_name: datum['away_team_three_letter_code'].downcase)
        home_team = find_team_record(short_name: datum['home_team_three_letter_code'].downcase)
        utc_start_time = Time.parse(datum['start_date'])
        {
          slug: "#{home_team.short_name}vs#{away_team.short_name}-#{utc_start_time.strftime('%m-%d-%Y')}",
          utc_start_time:, away_team:, home_team:
        }
      end

      def get_goal_data(match_id)
        begin
          raw_response = RestClient.get("#{BASE_URL}/#{match_id}/key_events?per_page=1000")
        rescue RestClient::ExceptionWithResponse => e
          e.response
        end
        JSON.parse(raw_response || '{}')
      end

      def create_goals_for(game:, data:)
        slugs = game.events.map(&:slug)
        data[:events]&.each do |goals|
          next if slugs.include?(goals['slug'])

          Event.create!(game:, team: data[:team], **goals)
        end
      end

      def find_team_record(short_name:)
        Team.joins(:league).where(teams: { short_name: }, leagues: { short_name: 'mls' }).first
      end

      def week_ago_week_from_now_data
        today = Time.now.strftime('%Y-%m-%d')
        [[7.day.ago.strftime('%Y-%m-%d'), today], [today, 7.day.from_now.strftime('%Y-%m-%d')]].map do |set|
          JSON.parse(RestClient.get(game_schedule_url(*set)))['schedule']
        rescue RestClient::NotFound
          [] # sometimes there is no data for a week, which means you return a 404 naturally
        end.flatten.uniq
      end

      def game_schedule_url(beg, fin)
        "#{BASE_URL}/seasons/MLS-SEA-0001K9?match_date[gte]=#{beg}&match_date[lte]=#{fin}&competition_id=MLS-COM-000001"
      end

      def match_data(match_id:)
        data = get_goal_data(match_id)
        return {} if data.empty?

        goal_events = data['events']&.select { it['sub_type'].eql?('goals') }
        event_data = goal_events.map { it['event'] }
        goal_hash = goal_data(event_data)
        data['match_info'].merge('goals' => goal_hash)
      end

      def goal_data(event_data)
        event_data.each_with_object(Hash.new { |h, k| h[k] = [] }) do |goal_data, hsh|
          team_abbr = goal_data['three_letter_code'].downcase
          timestamp = Time.parse(goal_data['event_time'])
          goal = {
            'period' => goal_data['game_section'] == 'firstHalf' ? 1 : 2,
            'slug' => "#{team_abbr}_#{timestamp.to_i}",
            'utc_occurred_at' => timestamp, 'event_type' => 'goal'
          }
          hsh[team_abbr] = hsh[team_abbr].push(goal)
        end
      end
    end
  end
end
