class CompanyUserGroups < ActiveRecord::Migration
  def self.up
    create_table :company_user_groups do |t|
      t.integer   :user_id
      t.integer   :access_type
      t.integer   :company_id
      t.timestamps
    end
  end

  def self.down
    drop_table :company_user_groups
  end
end
