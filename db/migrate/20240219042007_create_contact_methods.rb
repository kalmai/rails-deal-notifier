class CreateContactMethods < ActiveRecord::Migration[7.1]
  def change
    create_table :contact_methods do |t|
      t.integer :contact_type
      t.string :contact_detail
      t.boolean :enabled

      t.timestamps
    end
  end
end
