class CreateSubscriptions < ActiveRecord::Migration[7.1]
  def change
    create_table :subscriptions do |t|
      t.references :user, index: true, foreign_key: true
      t.references :promotion, index: true, foreign_key: true
      t.boolean :enabled, default: true
      t.integer :redemption_count, default: 0

      t.timestamps
    end
  end
end
