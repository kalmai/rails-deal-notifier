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

    add_column :games, :league_specifics, :hstore, default: {}, if_exists: true
    add_column :games, :has_consumed_results, :boolean, default: false, if_exists: true
    add_column :games, :slug, :string, null: false, if_exists: true

    add_index :games, :has_consumed_results, algorithm: :concurrently, if_not_exists: true
    add_index :games, :slug, algorithm: :concurrently, if_not_exists: true
  end

  def down
    safety_assured do
      remove_index :games, :slug, algorithm: :concurrently, if_not_exists: true
      remove_index :games, :has_consumed_results, algorithm: :concurrently, if_not_exists: true
      remove_column :games, :has_consumed_results, :boolean, if_exists: true
      remove_column :games, :slug, :string, if_exists: true
      remove_column :games, :league_specifics, :hstore, default: {}, if_exists: true
      change_column_null :games, :home_team_id, true
      change_column_null :games, :away_team_id, true

      remove_reference :games, :home_team, index: { algorithm: :concurrently }, if_not_exists: true
      remove_reference :games, :away_team, index: { algorithm: :concurrently }, if_not_exists: true
    end
  end
end
