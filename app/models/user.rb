# frozen_string_literal: true

class User < ApplicationRecord
  validates :postal, :region, :country, :timezone, presence: true

  has_many :contact_methods, dependent: :destroy do
    def detail_for(type:)
      find_by(contact_type: type).contact_detail
    end
  end
  has_many :subscriptions, dependent: :destroy
  has_many :promotions, through: :subscriptions
  accepts_nested_attributes_for :contact_methods
  # TODO: add roles with permissions i.e. admin:god, moderator:high, consumer:normal, visitor:low

  after_create :populate_default_promotions

  private

  def populate_default_promotions
    promotions << Team.where(region:)&.map(&:promotions)&.flatten
  end
end
