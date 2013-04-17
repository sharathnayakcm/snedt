class AddBrandIdToPostServiceGroups < ActiveRecord::Migration
  def self.up
    add_column :post_service_groups ,:brand_id,:integer
  end

  def self.down
  end
end
