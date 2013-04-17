class AddBrandParentId < ActiveRecord::Migration
  def self.up
    add_column  :brands, :parent_id, :integer
  end

  def self.down
    remove_column  :brands, :parent_id
  end
end
