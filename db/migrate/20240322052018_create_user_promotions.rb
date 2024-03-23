class CreateUserPromotions < ActiveRecord::Migration[7.1]
  def change
    create_table :user_promotions do |t|
      t.references :user, index: true, foreign_key: true
      t.references :promotion, index: true, foreign_key: true
      t.boolean :enabled, default: true
      t.integer :redemption_count, default: 0

      t.timestamps
    end
  end
end
