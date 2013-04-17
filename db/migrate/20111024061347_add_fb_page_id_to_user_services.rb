class AddFbPageIdToUserServices < ActiveRecord::Migration
  def self.up
    add_column :brand_services, :fb_page_id, :string
    add_column :user_services, :fb_page_id, :string
  end

  def self.down
    remove_column :brand_services, :fb_page_id
    remove_column :user_services, :fb_page_id
  end
end
