# frozen_string_literal: true

class User < ApplicationRecord
  validates :postal, :region, :country, :timezone, presence: true

  has_many :contact_methods, dependent: :destroy
  has_many :subscriptions
  has_many :promotions, through: :subscriptions
  accepts_nested_attributes_for :contact_methods
  # TODO: add roles with permissions i.e. admin:god, moderator:high, consumer:normal, visitor:low

  after_create :populate_default_promotions

  private

  def populate_default_promotions
    promotions << Team.where(region:)&.map(&:promotions)&.flatten
  end
end
