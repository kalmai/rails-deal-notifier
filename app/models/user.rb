# frozen_string_literal: true

class User < ApplicationRecord
  validates :postal, presence: true

  has_many :contact_methods
  accepts_nested_attributes_for :contact_methods
end
