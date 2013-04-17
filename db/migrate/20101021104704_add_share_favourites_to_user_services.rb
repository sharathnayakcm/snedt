class AddShareFavouritesToUserServices < ActiveRecord::Migration
  def self.up
    add_column :user_services, :share_favourites, :boolean
  end

  def self.down
    remove_column :user_services, :share_favourites
  end
end
