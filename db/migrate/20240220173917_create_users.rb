class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :postal, limit: 15
      t.string :region
      t.string :country
      t.string :timezone
      # example: ActiveSupport::TimeZone.find_tzinfo("America/Chicago").now # yields current time in that zone

      t.timestamps
    end
  end
end
