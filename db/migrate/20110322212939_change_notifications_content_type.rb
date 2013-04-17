class ChangeNotificationsContentType < ActiveRecord::Migration
  def self.up
    change_column :notifications, :content, :text
  end

  def self.down
    change_column :notifications, :content, :string
  end
end
