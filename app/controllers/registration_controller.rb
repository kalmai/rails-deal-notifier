# frozen_string_literal: true

class RegistrationController < ApplicationController
  def index
    session[:geocode_data] = request.location.data
    @user = User.new
    @user.contact_methods.build
    render :index
  end

  def create
    @user = User.new
    notice = { successful: false, message: 'Something went wrong, please try again.' }
    if params.dig(:user, :contact_methods_attributes, '0', :contact_detail) && params.dig(:user, :postal)
      create_user_contact_method
    end
    if @user.persisted?
      Notify::WelcomeJob.perform_later(user: @user)
      notice = { successful: true, message: 'You will be receiving a welcome email shortly.' }
    end
    redirect_to root_path, notice:
  end

  def redirect_to_promotions
    redirect_to "/promotions/#{params.dig(:user, :postal)}"
  end

  private

  def create_user_contact_method
    User.transaction { @user = User.create!(user_data) }
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.info("RegistrationController#create_user_contact_method failed with: #{e}")
  end

  def user_data
    postal = registration_params.dig(:user, :postal)
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
    [registration_params.dig(:user, :contact_methods_attributes, '0').merge!(contact_type: :email, enabled: true)]
  end

  def registration_params
    params.permit(user: [:postal, { contact_methods_attributes: :contact_detail }])
  end
end
