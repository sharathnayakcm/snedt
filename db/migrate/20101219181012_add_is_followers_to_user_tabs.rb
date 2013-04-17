class AddIsFollowersToUserTabs < ActiveRecord::Migration
  def self.up
    add_column :user_tabs, :is_followers, :boolean, :default => false
    add_column :user_tabs, :is_followings, :boolean, :default => false
    add_column :user_tabs, :is_friends, :boolean, :default => false
    add_column :user_tabs, :is_fb, :boolean, :default => false
    add_column :user_tabs, :is_twitter, :boolean, :default => false
    add_column :user_tabs, :is_flickr, :boolean, :default => false
    add_column :user_tabs, :user_name, :string
  end

  def self.down
    remove_column :user_tabs, :is_followers
    remove_column :user_tabs, :is_followings
    remove_column :user_tabs, :is_friends
    remove_column :user_tabs, :is_fb
    remove_column :user_tabs, :is_twitter
    remove_column :user_tabs, :is_flickr
    remove_column :user_tabs, :user_name
  end
end
