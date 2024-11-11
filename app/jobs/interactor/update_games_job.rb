# frozen_string_literal: true

module Interactor
  class UpdateGamesJob < ApplicationJob
    queue_as :high_priority

    def perform
      League.all.each do |league|
        "Interactor::#{league.short_name.titleize}".constantize.update_games if league.in_season?
      end
    end
  end
end
