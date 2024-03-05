# frozen_string_literal: true

class User < ApplicationRecord
  validates :postal, :region, :country, :timezone, presence: true

  has_many :contact_methods, dependent: :destroy
  accepts_nested_attributes_for :contact_methods
  # TODO: add roles with permissions i.e. admin:god, moderator:high, consumer:normal, visitor:low
end
