class AddDetaiulsToAbuseContents < ActiveRecord::Migration
  def self.up
     add_column :abuse_contents,:stream_id,:integer
     add_column :abuse_contents,:user_comments,:string
  end

  def self.down
    remove_column :abuse_contents,:stream_id
    remove_column :abuse_contents,:user_comments
  end
end
