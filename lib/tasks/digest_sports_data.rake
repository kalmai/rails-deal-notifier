# frozen_string_literal: true

namespace :digest_sports_data do
  desc 'https://en.wikipedia.org/wiki/Major_professional_sports_teams_of_the_United_States_and_Canada' \
       'consume wikipedia link after processing it into csv with: https://wikitable2csv.ggor.de/' \
       'invoke with `rake digest_sports_data:wikipedia_ca_us_teams <csv-file-here>`'
  task wikipedia_ca_us_teams: :environment do
    data = CSV.read(ARGV.second, headers: true, header_converters: :symbol)
    data.each do |datum|
      country = Geocoder.search(
        "#{datum[:stateprovince]},#{datum[:city]}", params: { countrycodes: 'us,ca' }
      ).first.data['properties']['country_code']
      Team.create!(
        full_name: datum[:team], short_name: nil,
        # https://en.wikipedia.org/wiki/Wikipedia:WikiProject_National_Football_League/National_Football_League_team_abbreviations
        # may need to get a lookup for this?
        region: datum[:stateprovince].downcase, country:,
        league: League.find_by(short_name: datum[:league].downcase)
      )
      print '.'
    end
  end
end
