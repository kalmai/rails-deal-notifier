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
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.info("RegistrationController#create_user_contact_method failed with: #{e}")
  end

  def user_data
    postal = registration_params[:postal]
    { postal:, contact_methods_attributes: }.merge(location_data(postal:))
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

  def contact_methods_attributes
    [{ contact_detail: registration_params[:contact_detail], contact_type: :email, user: @user, enabled: true }]
  end

  def registration_params
    params.permit(:contact_detail, :postal)
  end
end
