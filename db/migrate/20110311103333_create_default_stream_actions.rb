class CreateDefaultStreamActions < ActiveRecord::Migration
  def self.up
    create_table :default_stream_actions do |t|
      t.integer :user_id
      t.boolean :allow_comments, :default => true
      t.boolean :review, :default => true
      t.boolean :retweet, :default => true
      t.boolean :favourite, :default => true
      t.timestamps
    end
  end

  def self.down
    drop_table :default_stream_actions
  end
end
