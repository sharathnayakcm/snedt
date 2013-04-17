class AddProfileImageUrlToUserServices < ActiveRecord::Migration
  def self.up
    add_column :user_services, :profile_image_url, :string
  end

  def self.down
    remove_column :user_services, :profile_image_url
  end
end
