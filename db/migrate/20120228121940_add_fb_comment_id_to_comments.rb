class AddFbCommentIdToComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :fb_comment_id, :string
    add_column :comments, :twitter_reply_id, :string
  end

  def self.down
    remove_column :comments, :fb_comment_id
    remove_column :comments, :twitter_reply_id
  end
end
