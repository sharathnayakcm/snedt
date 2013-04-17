class AddArabicContentToNotifications < ActiveRecord::Migration
  def self.up
    add_column :notifications, :subject_arabic, :string
    add_column :notifications, :content_arabic, :text
    add_column :services, :notes_arabic, :text
  end

  def self.down
    remove_column :notifications, :subject_arabic
    remove_column :notifications, :content_arabic
    remove_column :services, :notes_arabic
  end
end
