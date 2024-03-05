class CreateLeagues < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    create_table :leagues do |t|
      # ["NHL", "NFL", "MLB", "NBA", "MLS", "CFL"] all leagues yielded from wikipedia table
      # seems to be missing womens leagues...
      t.string :full_name
      t.string :short_name
      t.integer :start_month
      t.string :end_month
        # safety_assured {remove_reference :teams, :league}

      t.timestamps
    end

    reversible do |direction|
      direction.up do
        add_reference :teams, :league, index: { algorithm: :concurrently }
      end
      direction.down do
        remove_reference :teams, :league
      end
    end
  end
end
