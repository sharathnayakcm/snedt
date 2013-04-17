class AddUserServiceIdsToCustomTabs < ActiveRecord::Migration
  def self.up
    add_column :custom_tabs, :user_service_ids, :string
  end

  def self.down
    remove_column :custom_tabs, :user_service_ids
  end
end