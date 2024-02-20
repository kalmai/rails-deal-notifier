class CreateContactMethods < ActiveRecord::Migration[7.1]
  def change
    create_table :contact_methods do |t|
      t.integer :contact_type, null: false
      t.string :contact_detail, null: false
      t.boolean :enabled, default: true

      t.timestamps
    end
  end
end
