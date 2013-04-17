class AddDisallowCommentsToUserServices < ActiveRecord::Migration
  def self.up
    add_column :user_services, :disallow_comments, :boolean, :default => false
  end

  def self.down
    remove_column :user_services, :disallow_comments
  end
end
