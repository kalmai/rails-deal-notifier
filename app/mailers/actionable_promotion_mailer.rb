# frozen_string_literal: true

class ActionablePromotionMailer < ApplicationMailer
  def notify
    @user = params[:user]
    @promotions = params[:promotions]
    to = @user.contact_methods.detail_for(type: 'email')
    mail(to:, subject: 'Sports DealNotifier: Actionable Promotions')
  end
end
