class CreateExpressions < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    create_table :expressions do |t|
      t.string :left
      t.string :operand
      t.string :right

      t.timestamps
    end

    reversible do |direction|
      direction.up do
        add_reference :expressions, :promotion, index: { algorithm: :concurrently }
      end
      direction.down do
        remove_reference :expressions, :promotion
      end
    end
  end
end
