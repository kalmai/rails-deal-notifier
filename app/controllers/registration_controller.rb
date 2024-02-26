# frozen_string_literal: true

class RegistrationController < ApplicationController
  def index
    session[:geocode_data] = Geocoder.search(request.remote_ip)&.first&.data
    render :index
  end

  def create
    create_user_contact_method if registration_params[:contact_detail] && registration_params[:postal]
    ApplicationMailer.with(email: @user.contact_methods.last.contact_detail).welcome_email.deliver_now if @user
    redirect_to root_path, notice: 'Success!'
  end

  private

  def create_user_contact_method
    User.transaction { @user = User.create!(**(postal_codes_match? ? assumed_data : provided_data)) }
  rescue ActiveRecord::RecordInvalid
    # do some logging in the future?
  end

  def assumed_data
    {
      postal: registration_params[:postal],
      region: session.dig(:geocode_data, 'region').downcase,
      country: session.dig(:geocode_data, 'country').downcase,
      timezone: session.dig(:geocode_data, 'timezone').downcase,
      contact_methods_attributes:
    }
  end

  def provided_data
    data = Geocoder.search(registration_params[:postal], params: { countrycodes: 'us,ca' }).first.data
    {
      postal: registration_params[:postal],
      region: data.dig('address', 'state').downcase,
      country: data.dig('address', 'country_code').downcase,
      timezone: nil,
      contact_methods_attributes:
    }
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
