class AddIsNotificationToNotifications < ActiveRecord::Migration
  def self.up
    add_column :notifications, :is_notification, :boolean, :default => true
    add_column :notifications, :delivery_day, :integer
  end

  def self.down
    remove_column :notifications, :is_notification
    remove_column :notifications, :delivery_day
  end
end
