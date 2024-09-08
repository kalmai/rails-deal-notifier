# frozen_string_literal: true

class RegistrationMailer < ApplicationMailer
  def welcome_email
    @user = params[:user]
    params[:actionable_promotions] = actionable_promotions(@user)
    params[:email] = @user.contact_methods.detail_for(type: 'email')
    mail(to: params[:email], subject: 'Welcome to Sports DealNotifier')
  end

  private

  def actionable_promotions(user)
    user.promotions.map do |promotion|
      promotion.attributes.with_indifferent_access if promotion.evaluate(timezone: user.timezone)
    end.compact
  end
end
