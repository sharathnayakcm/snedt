class AddShareContentToUserServices < ActiveRecord::Migration
  def self.up
    add_column :user_services, :share_content, :boolean
  end

  def self.down
    remove_column :user_services, :share_content
  end
end
