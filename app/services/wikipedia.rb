# frozen_string_literal: true

module Wikipedia
  class << self
    def seed_teams
      League.all.each do |league|
        html = wiki_html(league.short_name)
        teams = build_initial_team_hash(html, league)
        modify_location_data(teams)
        add_abbrev_data(teams, league.short_name)
        teams.each { Team.create!(**self.it) }
      end
    end

    private

    def seed_config
      @seed_config ||= YAML.load_file('config/wiki_seeder.yml').with_indifferent_access
    end

    def add_abbrev_data(teams, league)
      abbrev_data = api_team_data(league)
      teams.each do |team|
        team.merge!({ short_name: return_matching_abbrev(abbrev_data, team[:full_name]) })
      end
    end

    def modify_location_data(teams)
      teams.each do |team|
        region_and_country = region_country(team.delete(:location_string))
        team.merge!({ region: region_and_country.first, country: region_and_country.last })
      end
    end

    def api_team_data(league)
      api_options = seed_config.dig(league, :sport_api)
      league_api_data(api_options).each_with_object({}) do |datum, hsh|
        full_name = datum.dig(*api_options[:full_name_path]).downcase
        abbreviation = datum.dig(*api_options[:abbrev_path]).downcase
        hsh[full_name] = abbreviation
      end
    end

    def league_api_data(api_options)
      raw_response = RestClient.get("#{api_options[:url]}#{league_api_specific_params(api_options)}")
      data = JSON.parse(raw_response.body)
      api_options[:data_path] ? data.dig(*api_options[:data_path]) : data
    end

    def league_api_specific_params(api_options)
      additional_param_hash = api_options[:additional_params]
      return '' unless additional_param_hash.present?

      additional_param_hash[:seasonId] = Time.zone.now.year if additional_param_hash.keys.include?('seasonId')
      "&#{additional_param_hash.to_param}"
    end

    def wiki_html(league)
      params = seed_config[:wiki_base_params].merge(seed_config.dig(league, :wiki_specific_params)).to_param
      raw_response = RestClient.get("#{seed_config[:wiki_query]}#{params}")
      JSON.parse(raw_response.body).dig('parse', 'text', '*')
    end

    def parsed_html_data(html)
      doc = Nokogiri::HTML.parse(html)
      # using .first to get the first table in the section
      # drop(1) drops the table headers
      doc.css('table.wikitable > tbody').first.css('tr').drop(1)
    end

    def build_initial_team_hash(html, league)
      parsed_html_data(html).map do |row|
        row_data = row.elements.to_a.map(&:text).map { _1.downcase.strip }
        row_data.shift while row_data.first.in?(seed_config.dig(league.short_name, :options, :excluded_wiki_columns))
        # assuming the data always follows the pattern |team|location|
        { full_name: row_data.first, location_string: row_data.second, league: }
      end
    end

    def region_country(city_state)
      data = Geocoder.search(city_state, params: { countrycodes: 'us,ca' }).first.data['properties']
      data.slice('state_code', 'country_code').values.map(&:downcase)
    end

    def return_matching_abbrev(data, team_name)
      return data[team_name] if data[team_name]

      found_key = FuzzyMatch.new(data.keys).find(team_name)
      data[found_key]
    end
  end
end
