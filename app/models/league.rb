# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'

class League < ApplicationRecord
  extend T::Sig

  validates :full_name, :short_name, :start_month, :end_month, presence: true

  has_many :teams, dependent: :destroy

  sig { returns(Range) }
  def season_range
    season_start_date..season_end_date
  end

  private

  sig { returns(Time) }
  def season_start_date
    Time.new(Time.now.year, start_month).beginning_of_month
  end

  sig { returns(Time) }
  def season_end_date
    em = end_month
    if em&.slice!('+').present?
      Time.new(Time.now.next_year.year, em.to_i).at_end_of_month
    else
      Time.new(Time.now.year, em.to_i).at_end_of_month
    end
  end
end
