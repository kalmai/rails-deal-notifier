class AddGoals < ActiveRecord::Migration[7.1]
  def change
    create_table :goals do |t|
      t.integer :period
      t.datetime :utc_scored_at

      t.timestamps
    end
  end
end
