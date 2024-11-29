# frozen_string_literal: true

class WelcomeMailer < ApplicationMailer
  def send_email
    @user = params[:user]
    @actionable_promotions = actionable_promotions(@user)
    @email = @user.contact_methods.detail_for(type: 'email')
    mail(to: @email, subject: 'Welcome to Sports DealNotifier')
  end

  private

  def actionable_promotions(user)
    user.promotions.map do |promotion|
      promotion.attributes.with_indifferent_access if promotion.evaluate_most_recent_game
    end.compact
  end
end
