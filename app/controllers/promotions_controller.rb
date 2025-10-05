# frozen_string_literal: true

class PromotionsController < ApplicationController
  def index
    location_data = location_data(postal: params[:postal]) # Rails.cache.read('location_data') ||
    in_season_leagues = League.select(&:in_season?).map(&:id)
    teams = Team.where(league_id: in_season_leagues, country: location_data[:country], region: location_data[:region])
    # Rails.cache.write('location_data', location_data, expires_in: 30.minutes)
    @promotions = teams.map(&:promotions).flatten
  end

  private

  def location_data(postal:)
    data = Geocoder.search(postal, params: { countrycodes: 'us,ca', type: :postcode }).first&.data&.dig('properties')
    return {} unless data

    {
      region: data['state_code'].downcase,
      country: data['country_code'].downcase,
      timezone: data.dig('timezone', 'name')
    }
  end
end
