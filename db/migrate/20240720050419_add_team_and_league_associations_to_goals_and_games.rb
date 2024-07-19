class AddTeamAndLeagueAssociationsToGoalsAndGames < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
      add_reference :games, :league, index: { algorithm: :concurrently }, null: false
      add_reference :games, :home_team, index: { algorithm: :concurrently }, null: false
      add_reference :games, :away_team, index: { algorithm: :concurrently }, null: false

      add_reference :goals, :team, index: { algorithm: :concurrently }, null: false
  end
end
