class CreatePrivacyGroups < ActiveRecord::Migration
  def self.up
    create_table :privacy_groups do |t|
      t.integer "user_id"
      t.string  "name"
      t.string  "group_ids"
      t.string  "group_user_ids"
      t.string  "service_ids"
      t.timestamps
    end
  end

  def self.down
    drop_table :privacy_groups
  end
end
