class AddStatusToBrandUserGroups < ActiveRecord::Migration
  def self.up
    add_column :brand_user_groups, :status, :boolean, :default => true
  end

  def self.down
    remove_column :brand_user_groups, :status
  end
end
