# frozen_string_literal: true

module Evaluator
  class Client
    def initialize(promotion:, game:)
      @game = game
      @promotion = promotion
    end

    def evaluate(methods)
      methods.all? { |method| send(method) }
    end

    private

    def played?
      @game.try(:finalized) == true
    end

    def scored_in?
      return false unless played? && @game.events.present?

      @game.events.where(team_id: @promotion.team.id).any? do |goal|
        goal.period == @promotion.api_parameters['period'].to_i
      end
    end

    def first_goal?
      return false unless played? && @game.events.present?

      @game.events.first.team_id == @promotion.team.id
    end

    def perfect_defence?
      return false unless played?

      home? ? @game.away_goals.blank? : @game.home_goals.blank?
    end

    def goal_count_equal_or_above?
      return false unless played?

      @game.events.where(team_id: @promotion.team.id).count >= @promotion.api_parameters['goals_count'].to_i
    end

    def home?
      @game.home_team_id == @promotion.team.id
    end

    def away?
      @game.away_team_id == @promotion.team.id
    end

    def won?
      played? && (@game.home_goals.count <=> @game.away_goals.count) == (away? ? -1 : 1)
    end
  end
end
