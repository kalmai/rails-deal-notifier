# frozen_string_literal: true

module Upsert
  class Promotions
    class << self
      def execute_for(team:)
        upsert_data = data.dig(team.league.short_name, team.short_name)
        return unless upsert_data

        destroy_dead_promotions(team:, data: upsert_data)
        upsert(upsert_data, team)
        true
      end

      private

      def destroy_dead_promotions(team:, data:)
        no_longer_promoting_companies = team.promotions.map(&:company) - data.map { |d| d['company'] }
        no_longer_promoting_companies.each do |company|
          team.promotions.find_by(company:).destroy!
        end
      end

      def upsert(upsert_data, team)
        upsert_data.each do |data|
          promotion = team.promotions.select { it.company.eql?(data['company']) }.first
          promotion.nil? ? Promotion.create(data.merge(team_id: team.id)) : promotion.update(data)
        end
      end

      def data
        @data ||= YAML.load_file(Rails.root.join('config/upsert/promotions.yml'))
      end
    end
  end
end
