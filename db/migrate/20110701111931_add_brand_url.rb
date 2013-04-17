class AddBrandUrl < ActiveRecord::Migration
  def self.up
    add_column :brands, :brand_url, :string
  end

  def self.down
    remove_column :brands, :brand_url, :string
  end
end
