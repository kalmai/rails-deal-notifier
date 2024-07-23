class AddGoals < ActiveRecord::Migration[7.1]
  def change
    create_table :goals do |t|
      t.integer :period, null: false
      t.datetime :utc_scored_at, null: false

      t.timestamps
    end
  end
end
