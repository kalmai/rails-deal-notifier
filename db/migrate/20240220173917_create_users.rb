class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :zipcode, limit: 15

      t.timestamps
    end
  end
end
