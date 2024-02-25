# frozen_string_literal: true

class RegistrationController < ApplicationController
  def index
    session[:assumed_zipcode] = Geocoder.search(request.remote_ip)&.first&.data&.dig('postal')
    render :index
  end

  def create
    create_user_contact_method if registration_params[:contact_detail] && registration_params[:zipcode]
    ApplicationMailer.with(email: @user.contact_methods.last.contact_detail).welcome_email.deliver_now if @user
    redirect_to root_path, notice: 'Success!'
  end

  private

  def create_user_contact_method
    User.transaction do
      @user = User.create! \
        zipcode: registration_params[:zipcode],
        contact_methods_attributes: [
          { contact_detail: registration_params[:contact_detail], contact_type: :email, user: @user, enabled: true }
        ]
    end
  rescue ActiveRecord::RecordInvalid
    # do some logging in the future?
  end

  def registration_params
    params.permit(:contact_detail, :zipcode)
  end
end
