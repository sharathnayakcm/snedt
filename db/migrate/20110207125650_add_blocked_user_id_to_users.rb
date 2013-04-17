class AddBlockedUserIdToUsers < ActiveRecord::Migration
  def self.up
    add_column :users,  :blocked_user_id, :integer
  end

  def self.down
    remove_column :users,  :blocked_user_id, :integer
  end
end
