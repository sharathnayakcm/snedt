class AddFbPageNameToUserServices < ActiveRecord::Migration
  def self.up
    add_column :brand_services, :fb_page_name, :string
    add_column :user_services, :fb_page_name, :string
  end

  def self.down
    remove_column :brand_services, :fb_page_name
    remove_column :user_services, :fb_page_name
  end
end
