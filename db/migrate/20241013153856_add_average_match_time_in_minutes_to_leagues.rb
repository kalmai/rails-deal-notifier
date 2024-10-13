class AddAverageMatchTimeInMinutesToLeagues < ActiveRecord::Migration[7.2]
  def change
    add_column :leagues, :average_match_minutes, :integer

    League.all.each do |league|
      average_match_minutes = league.short_name.eql?('nhl') ? 150 : 120
      league.update(average_match_minutes:)
    end

    safety_assured { change_column_null(:leagues, :average_match_minutes, false) }
  end
end
