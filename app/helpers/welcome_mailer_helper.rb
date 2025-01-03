# frozen_string_literal: true

module WelcomeMailerHelper
  # TODO: refactor this into smaller methods?
  # rubocop:disable Metrics/AbcSize
  def defaulted_promotions(user)
    user.promotions.each_with_object({}) do |promo, data|
      league = promo.team.league.short_name
      team = promo.team.short_name
      data[league] = {} if data[league].blank?
      data[league][team] = [] if data[league][team].blank?
      data[league][team].push("#{promo.name}:#{promo.promo_type}")
    end
  end
  # rubocop:enable Metrics/AbcSize
end
