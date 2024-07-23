class AddGames < ActiveRecord::Migration[7.1]
  def change
    create_table :games do |t|
      t.datetime :utc_start_time, null: false

      t.timestamps
    end
  end
end
