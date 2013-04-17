class AddDisallowRetweetToStreams < ActiveRecord::Migration
  def self.up
    add_column :streams, :disallow_retweet, :boolean, :default => false
    add_column :streams, :retweeted, :boolean, :default => false
  end

  def self.down
    remove_column :streams, :disallow_retweet
    remove_column :streams, :retweeted
  end
end
