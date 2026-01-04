# frozen_string_literal: true

module Interactor
  class StoreGamesJob < ApplicationJob
    queue_as :low_priority

    def perform
      League.all.each do |league|
        "Interactor::#{league.short_name.titleize}".constantize.store_games
      end
    end
  end
end
