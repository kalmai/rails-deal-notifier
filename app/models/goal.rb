# frozen_string_literal: true

class Goal < ApplicationRecord
  belongs_to :game
  belongs_to :team
end
