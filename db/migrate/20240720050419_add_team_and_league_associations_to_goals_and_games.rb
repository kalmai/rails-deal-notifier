class AddTeamAndLeagueAssociationsToGoalsAndGames < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
      safety_assured do
        # remove_reference :games, :league
        # remove_reference :games, :home_team
        # remove_reference :games, :away_team
        # remove_column :games, :away_team_id
        # remove_column :games, :home_team_id
        # remove_column :games, :league_id
        # remove_column :goals, :team_id
      end
      add_reference :games, :league, index: { algorithm: :concurrently }
      add_reference :games, :home_team, index: { algorithm: :concurrently }
      add_reference :games, :away_team, index: { algorithm: :concurrently }

      add_reference :goals, :team, index: { algorithm: :concurrently }
  end
end
