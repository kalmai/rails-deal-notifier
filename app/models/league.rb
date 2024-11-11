# frozen_string_literal: true

class League < ApplicationRecord
  validates :full_name, :short_name, :start_month, :end_month, presence: true

  has_many :teams, dependent: :destroy

  def in_season?
    Time.current.between?(season_start_date, season_end_date)
  end

  private

  def season_start_date
    Time.new(Time.now.year, start_month).beginning_of_month
  end

  def season_end_date
    em = end_month
    if em.slice!('+').present?
      Time.new(Time.now.next_year.year, em.to_i).at_end_of_month
    else
      Time.new(Time.now.year, em.to_i).at_end_of_month
    end
  end
end
