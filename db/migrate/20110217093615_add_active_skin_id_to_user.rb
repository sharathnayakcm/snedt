class AddActiveSkinIdToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :active_skin_id, :integer
  end

  def self.down
    remove_column :users, :active_skin_id
  end
end
