class AddPreferredNotificationTime < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :notification_minute, :integer, default: 0
    add_column :users, :notification_hour, :integer, default: 6
  end
end
