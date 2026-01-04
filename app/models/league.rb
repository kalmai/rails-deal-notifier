# frozen_string_literal: true

class League < ApplicationRecord
  validates :full_name, :short_name, presence: true
  self.ignored_columns += %i[start_month end_month]

  has_many :teams, dependent: :destroy
end
