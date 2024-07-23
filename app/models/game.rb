# frozen_string_literal: true

class Game < ApplicationRecord
  belongs_to :league
  belongs_to :home_team, class_name: 'Team'
  belongs_to :away_team, class_name: 'Team'

  has_many :goals
  # has_many :goals
  # try to do another has many with the home/away team
end
