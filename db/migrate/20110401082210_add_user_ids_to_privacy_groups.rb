class AddUserIdsToPrivacyGroups < ActiveRecord::Migration
  def self.up
    add_column :privacy_groups, :user_ids, :string
  end

  def self.down
    remove_column :privacy_groups, :user_ids
  end
end
