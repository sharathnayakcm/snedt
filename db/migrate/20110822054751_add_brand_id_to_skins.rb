class AddBrandIdToSkins < ActiveRecord::Migration
  def self.up
    add_column :skins, :brand_id, :integer
  end

  def self.down
    remove_column :skins, :brand_id, :integer
  end
end
