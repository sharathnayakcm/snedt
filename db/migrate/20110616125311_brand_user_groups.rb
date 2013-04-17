class BrandUserGroups < ActiveRecord::Migration
  def self.up
    create_table :brand_user_groups do |t|
      t.integer   :user_id
      t.integer   :company_id
      t.integer   :brand_id
      t.integer   :access_type
      t.timestamps
    end
  end

  def self.down
    drop_table  :brand_user_groups
  end
end
