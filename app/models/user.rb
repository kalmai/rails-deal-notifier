# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'

class User < ApplicationRecord
  extend T::Sig

  validates :postal, :region, :country, :timezone, presence: true

  has_many :contact_methods, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :promotions, through: :subscriptions
  accepts_nested_attributes_for :contact_methods
  # TODO: add roles with permissions i.e. admin:god, moderator:high, consumer:normal, visitor:low

  after_create :populate_default_promotions

  private

  sig { returns(T::Boolean) }
  def populate_default_promotions
    transaction { promotions << Team.where(region:).map(&:promotions).flatten }
    true
  rescue ActiveRecord::RecordInvalid
    false
  end
end
