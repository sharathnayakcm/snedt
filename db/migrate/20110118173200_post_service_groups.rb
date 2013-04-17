class PostServiceGroups < ActiveRecord::Migration
  def self.up
    create_table :post_service_groups do |t|
      t.string   :name
      t.string   :service_ids
      t.integer   :post_type_id
    end
  end
  def self.down
    drop_table :post_service_groups
  end
end
