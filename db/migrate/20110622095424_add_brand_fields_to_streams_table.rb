class AddBrandFieldsToStreamsTable < ActiveRecord::Migration
  def self.up
    add_column :streams, :brand_service_id, :integer
    add_column :streams, :brand_id, :integer
    add_column :streams, :company_id, :integer
  end

  def self.down
    remove_column :streams, :brand_service_id
    remove_column :streams, :brand_id
    remove_column :streams, :company_id
  end
end
