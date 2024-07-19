# frozen_string_literal: true

class Game < ApplicationRecord
  has_one :league
  has_one :opponent, class_name: 'Game'
  has_one :team

  has_many :goals
end
