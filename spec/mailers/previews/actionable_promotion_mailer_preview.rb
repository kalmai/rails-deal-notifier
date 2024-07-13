# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/actionable_promotion_mailer
class ActionablePromotionMailerPreview < ActionMailer::Preview
  def notify
    ActionablePromotionMailer.with(user: User.first, promotions: Promotion.all).notify
  end
end
