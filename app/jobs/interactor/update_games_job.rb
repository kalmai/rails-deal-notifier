# frozen_string_literal: true

module Interactor
  class UpdateGamesJob < ApplicationJob
    queue_as :high_priority

    def perform
      Game.group(:league_id).map(&:league).each do |league|
        games = "Interactor::#{league.short_name.titleize}".constantize.update_games
        a = games.each { upsert_cache_game it }
        broadcast_to_streams(a)
      end
    end

    private

    # key is the region, expires_at will be one week, the value will be
    # value will be the activerecord game, promotion, and evaluation
    # check to see if game.events.last is different from the cached value
    #   then we update the cached value
    # now that we have a cache, we can start using it
    def upsert_cache_game(game)
      return unless game_updated?(game)

      game.teams.map do |team|
        Rails.cache.write(
          team.region,
          Game::Presenter.new(game),
          expires_at: 1.week.from_now
        )
      end
    end

    def game_updated?(game)
      game.events.last&.utc_occurred_at != most_recent_utc_occurred_at(game.teams.first.region)
    end

    def most_recent_utc_occurred_at(region)
      cached_value = Rails.cache.read(region)&.last_update_at
      return Time.now unless cached_value

      cached_value.utc_occurred_at
    end

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
