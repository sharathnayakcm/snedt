class AddShareStatusUpdateToUserServices < ActiveRecord::Migration
  def self.up
    add_column :user_services, :share_status_update, :boolean
  end

  def self.down
    remove_column :user_services, :share_status_update
  end
end
