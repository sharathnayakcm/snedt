class AddNameArabicToNotification < ActiveRecord::Migration
  def self.up
    add_column :notifications, :name_arabic, :string
  end

  def self.down
    remove_column :notifications, :name_arabic
  end
end
