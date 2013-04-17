class AddUserIdToPostServiceGroups < ActiveRecord::Migration
  def self.up
    add_column :post_service_groups, :user_id, :integer
  end

  def self.down
    remove_column :post_service_groups, :user_id
  end
end
