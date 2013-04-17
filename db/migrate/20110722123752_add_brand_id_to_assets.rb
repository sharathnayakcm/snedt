class AddBrandIdToAssets < ActiveRecord::Migration
  def self.up
    add_column :assets,:brand_id,:integer
  end

  def self.down
  end
end
