# frozen_string_literal: true

module Interactor
  class UpdateGamesJob < ApplicationJob
    queue_as :high_priority

    def perform
      League.all.each do |league|
        next unless league.in_season?

        games = "Interactor::#{league.short_name.titleize}".constantize.update_games # update game data
        broadcast_to_streams(possibly_affected_promotions(games)) # collect game promotions and broadcast updates
      end
    end

    private

    def possibly_affected_promotions(games)
      games.map(&:teams).flatten.uniq.map(&:promotions).flatten
    end

    def broadcast_to_streams(promotions)
      promotions.each { it.broadcast_update_to :promotions, locals: { actionable: it.evaluate_most_recent_game } }
    end
  end
end
