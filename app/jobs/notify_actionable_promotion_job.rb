# frozen_string_literal: true

class NotifyActionablePromotionJob < ApplicationJob
  queue_as :default

  def perform
    Promotion.all.each do |promotion|
    end
  end
end
