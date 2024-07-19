class AddGameAndGoals < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    create_table :games do |t|
      # GameResult = Struct.new(:won?, :goals, :away?, :opponent, :utc_start_time, keyword_init: true) do
      #   def initialize(*)
      #     super
      #     self.utc_start_time = utc_start_time
      #   end
      # end
      # TodayGame = Struct.new(:away?, :team_abbrev, :utc_start_time, keyword_init: true)
      #
      # GAME utc_start_time, team, opponent, goals, home_game (true, false), won (true, false)
      t.datetime :utc_start_time
      t.references :league
      t.references :team
      t.boolean :home_game
      t.boolean :won

      t.timestamps
    end

    add_reference :games, :opponent, index: { algorithm: :concurrently }

    create_table :goals do |t|
      # Goal = Struct.new(:period, :time, keyword_init: true)
      # GOAL period, score_time
      t.integer :period
      t.datetime :utc_scored_at
      t.belongs_to :game

      t.timestamps
    end
  end
end
