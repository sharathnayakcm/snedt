class ChagnePostServiceGroupsServiceIdsToUserServiceIds < ActiveRecord::Migration
  def self.up
    remove_column :post_service_groups, :service_ids
    add_column :post_service_groups, :user_service_ids, :string
  end

  def self.down
    add_column :post_service_groups, :service_ids, :string
    remove_column :post_service_groups, :user_service_ids
  end
end
