# frozen_string_literal: true

class RegistrationController < ApplicationController
  def index
    session[:geocode_data] = request.location.data
    render :index
  end

  def create
    create_user_contact_method if registration_params[:contact_detail] && registration_params[:postal]
    Registration::NotifyJob.perform_later(user: @user) if @user
    redirect_to root_path, notice: 'Success!'
  end

  private

  def create_user_contact_method
    User.transaction { @user = User.create!(user_data) }
  rescue ActiveRecord::RecordInvalid
    # do some logging in the future?
  end

  def user_data
    { postal: registration_params[:postal], contact_methods_attributes: }
      .merge(postal_codes_match? ? assumed_location_data : provided_location_data)
  end

  def assumed_location_data
    {
      region: session.dig(:geocode_data, 'region').downcase,
      country: session.dig(:geocode_data, 'country').downcase,
      timezone: session.dig(:geocode_data, 'timezone')
    }
  end

  def provided_location_data
    data = Geocoder.search(
      registration_params[:postal],
      params: { countrycodes: 'us,ca', type: :postcode }
    ).first.data['properties']
    { region: data['state'].downcase, country: data['country_code'].downcase, timezone: data.dig('timezone', 'name') }
  end

  def contact_methods_attributes
    [{ contact_detail: registration_params[:contact_detail], contact_type: :email, user: @user, enabled: true }]
  end

  def postal_codes_match?
    session.dig(:geocode_data, 'postal') == registration_params[:postal]
  end

  def registration_params
    params.permit(:contact_detail, :postal)
  end
end
