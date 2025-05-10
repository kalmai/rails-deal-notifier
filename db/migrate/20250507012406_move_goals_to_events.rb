class MoveGoalsToEvents < ActiveRecord::Migration[8.0]
  def change
    safety_assured do
      rename_table :goals, :events

      add_column :events, :event_type, :integer, null: false
      add_column :events, :slug, :string, null: false
      rename_column :events, :utc_scored_at, :utc_occurred_at
      rename_column :games, :has_consumed_results, :finalized

      add_index :events, :slug, unique: true
    end
  end
end
