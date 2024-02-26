class CreateTeams < ActiveRecord::Migration[7.1]
  def change
    create_table :teams do |t|
      t.string :full_name
      t.string :short_name
      t.string :region
      t.string :country
      # https://www.stadium-maps.com/facts/sports-franchises.html # yields a table with all teams and their regions

      t.timestamps
    end
  end
end
