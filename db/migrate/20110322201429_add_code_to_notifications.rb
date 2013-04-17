class AddCodeToNotifications < ActiveRecord::Migration
  def self.up
    add_column :notifications, :code, :string
    add_column :notifications, :active, :boolean, :default => true
  end

  def self.down
    remove_column :notifications, :code
    remove_column :notifications, :active
  end
end
