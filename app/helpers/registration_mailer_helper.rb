# frozen_string_literal: true

module RegistrationMailerHelper
  def defaulted_promotions(user)
    user.promotions.each_with_object({}) do |promo, data|
      league = promo.team.league.short_name
      team = promo.team.short_name
      data[league] = {} if data[league].blank?
      data[league][team] = [] if data[league][team].blank?
      data[league][team].push("#{promo.name}:#{promo.promo_type}")
    end
  end
end
