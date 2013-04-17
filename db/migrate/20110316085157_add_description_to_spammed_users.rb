class AddDescriptionToSpammedUsers < ActiveRecord::Migration
  def self.up
    add_column :spammed_users, :description, :text
  end

  def self.down
    remove_column :spammed_users, :description
  end
end
