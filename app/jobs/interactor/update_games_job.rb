# frozen_string_literal: true

module Interactor
  class UpdateGamesJob < ApplicationJob
    queue_as :high_priority

    def perform
      Game.group(:league_id).map(&:league).each do |league|
        games = "Interactor::#{league.short_name.titleize}".constantize.update_games # update game data
        broadcast_to_streams(possibly_affected_promotions(games)) # collect game promotions and broadcast updates
      end
    end

    private

    def possibly_affected_promotions(games)
      games.map(&:teams).flatten.uniq.map(&:promotions).flatten
    end

    def broadcast_to_streams(promotions)
      promotions.each do |promotion|
        promotion.broadcast_update_to \
          :promotions,
          partial: 'promotions/promotion_table_data'
      end
    end
  end
end
