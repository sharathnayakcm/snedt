class AddFriendsFindToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :friends_find, :boolean , :default => false
  end

  def self.down
    remove_column :users, :friends_find
  end
end
