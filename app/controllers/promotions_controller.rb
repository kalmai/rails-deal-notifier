# frozen_string_literal: true

class PromotionsController < ApplicationController
  def show
    location_data = location_data(postal: params[:id]) # this needs to be changed to postal at some point
    # get arr of which leagues are in season
    # get all the teams that match the location and are included in the arr of in season leagues
    in_season_leagues = League.select(&:in_season?).map(&:id)
    teams = Team.where(league_id: in_season_leagues, country: location_data[:country], region: location_data[:region])
    render json: promos_available_for_teams(teams, location_data[:timezone])
  end

  private

  def promos_available_for_teams(teams, timezone)
    teams.map do |team|
      team.promotions.select do |promo|
        Time.use_zone(timezone) do
          promo.attributes.with_indifferent_access if promo.evaluate_most_recent_game
        end
      end
    end
  end

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
