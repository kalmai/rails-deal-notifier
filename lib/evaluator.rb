# frozen_string_literal: true

module Evaluator
  class Client
    def initialize(timezone:, team_id:, game:)
      @timezone = timezone
      @team_id = team_id
      @game = game
    end

    def played?
      @played ||= Time.use_zone(@timezone) do
        @game.has_consumed_results && @game.utc_start_time.in_time_zone(@timezone).yesterday?
      end || false
    end

    def scored_in?(period:)
      return false unless played? && @game.goals.present?

      @game.goals.any? { _1.period == period.to_i }
    end

    def first_goal?
      return false unless played?

      @game.goals.first.team_id == @team_id
    end

    def perfect_defence?
      return false unless played?

      @game.away_goals.blank?
    end

    def goal_count_equal_or_above?
      return false unless played?

      @game.goals.where(team_id: @team_id)
    end

    def home?
      @game.home_team_id == @team_id
    end

    def away?
      @game.away_team_id == @team_id
    end

    def won?
      played? && (@game.home_goals.count <=> @game.away_goals.count) == (away? ? -1 : 1)
    end
  end
end
