# frozen_string_literal: true

class CleanUpOldGames < ApplicationJob
  queue_as :default

  # if there are promotions that last longer than a week after a game, it may be worth re-visiting
  # how we clean up older games
  def perform
    Game.where('utc_start_time <= ?', 1.weeks.ago).each(&:destroy!)
  end
end
