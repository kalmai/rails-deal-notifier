# frozen_string_literal: true

require 'rest-client'

module Nhl
  class Client
    BASE_URL = 'https://api-web.nhle.com'.freeze

    class << self
      def hello
        'world'
      end

      def scored_within_period_number
      end

      # commento
      def results_for_today
        raw_response = RestClient.get("#{BASE_URL}/v1/score/now")
        @results_for_today ||= JSON.parse(raw_response)['games']
      end
    end
  end
end
