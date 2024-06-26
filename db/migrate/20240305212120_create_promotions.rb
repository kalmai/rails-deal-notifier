class CreatePromotions < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!
  enable_extension :hstore unless extension_enabled?(:hstore)

  def change
    create_table :promotions do |t|
      t.string :company
      t.string :name
      t.integer :promo_type
      t.string :promo_code
      t.string :source_url
      t.integer :redemption_limiter # enum i.e. seasonal, lifetime, count, absense of a limiter means there is no limit
      t.integer :redemption_count # season:1, lifetime:1, nil:nil
      t.integer :hours_valid
      t.string :timing_methods, array: true, default: []
      t.hstore :timing_parameters
      t.string :api_methods, array: true, default: []
      t.hstore :api_parameters

      t.timestamps
    end

    reversible do |direction|
      direction.up do
        add_reference :promotions, :team, index: { algorithm: :concurrently }
      end
      direction.down do
        remove_reference :promotions, :team
      end
    end
  end
end
