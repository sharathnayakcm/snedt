class AddIsBlockedToFollowers < ActiveRecord::Migration
  def self.up
    add_column :followers, :is_blocked, :boolean, :default => false
  end

  def self.down
     remove_column :followers, :is_blocked
  end
end

