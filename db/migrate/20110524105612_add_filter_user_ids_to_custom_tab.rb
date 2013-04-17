class AddFilterUserIdsToCustomTab < ActiveRecord::Migration
  def self.up
    remove_column :custom_tabs, :filter_user_id
    add_column :custom_tabs, :filter_user_ids, :string
  end

  def self.down
    remove_column :custom_tabs, :filter_user_ids
  end
end
