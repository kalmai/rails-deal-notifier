class AssociateGamesToGoals < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_reference :goals, :game, index: { algorithm: :concurrently }, null: false
  end
end
