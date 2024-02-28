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
      Team.create!(full_name: datum[:team], short_name: nil, region: datum[:stateprovince], country:)
      print '.'
    end
  end
end
