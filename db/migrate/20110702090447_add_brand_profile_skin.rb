class AddBrandProfileSkin < ActiveRecord::Migration
  def self.up
    add_column :brands, :active_skin_id, :integer
  end

  def self.down
    remove_column :brands, :active_skin_id, :integer
  end
end
