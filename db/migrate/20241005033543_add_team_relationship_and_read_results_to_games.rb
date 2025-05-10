class AddTeamRelationshipAndReadResultsToGames < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      remove_column :games, :home_team, :bigint, if_exists: true
      remove_column :games, :away_team, :bigint, if_exists: true
      remove_column :games, :away_team_id, :bigint, if_exists: true

      add_reference :games, :home_team, index: { algorithm: :concurrently }, if_not_exists: true
      add_reference :games, :away_team, index: { algorithm: :concurrently }, if_not_exists: true
      change_column_null :games, :home_team_id, false
      change_column_null :games, :away_team_id, false
    end

    add_column :games, :league_specifics, :hstore, default: {}
    add_column :games, :has_consumed_results, :boolean, default: false
    add_column :games, :slug, :string, null: false

    add_index :games, :has_consumed_results, algorithm: :concurrently
    add_index :games, :slug, algorithm: :concurrently
  end

  def down
    safety_assured do
      remove_index :games, :slug, algorithm: :concurrently
      remove_index :games, :has_consumed_results, algorithm: :concurrently
      remove_column :games, :has_consumed_results, :boolean
      remove_column :games, :slug, :string
      remove_column :games, :league_specifics, :hstore, default: {}
      change_column_null :games, :home_team_id, true
      change_column_null :games, :away_team_id, true

      remove_reference :games, :home_team, index: { algorithm: :concurrently }
      remove_reference :games, :away_team, index: { algorithm: :concurrently }
    end
  end
end
