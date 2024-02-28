class CreateLeagues < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    create_table :leagues do |t|
      # ["NHL", "NFL", "MLB", "NBA", "MLS", "CFL"] all leagues yielded from wikipedia table
      t.string :full_name
      t.string :short_name
      t.datetime :start_at
      t.datetime :end_at

      add_reference :teams, :league, index: { algorithm: :concurrently }

      t.timestamps
    end
  end
end
