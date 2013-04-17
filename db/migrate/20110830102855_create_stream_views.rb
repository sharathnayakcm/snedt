class CreateStreamViews < ActiveRecord::Migration
  def self.up
    create_table :stream_views do |t|
      t.integer :stream_id
      t.integer :user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :stream_views
  end
end
