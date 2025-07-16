# frozen_string_literal: true

class CleanUpOldGames < ApplicationJob
  queue_as :default

  def perform
    Game.where(finalized: true).map do |game|
      game.destroy! if (game.utc_start_time + 1.week) < Time.current
    end
  end
end
