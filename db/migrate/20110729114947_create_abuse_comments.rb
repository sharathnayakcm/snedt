class CreateAbuseComments < ActiveRecord::Migration
  def self.up
    create_table :abuse_comments do |t|
      t.integer :stream_id
      t.string :user_comments
      t.timestamps
    end
  end

  def self.down
    drop_table :abuse_comments
  end
end
