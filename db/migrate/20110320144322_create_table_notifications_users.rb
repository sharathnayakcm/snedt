class CreateTableNotificationsUsers < ActiveRecord::Migration
  def self.up
    create_table :notifications_users, :id => false do |t|
      t.integer :notification_id
      t.integer :user_id
    end
  end

  def self.down
    drop_table :notifications_users
  end
end
