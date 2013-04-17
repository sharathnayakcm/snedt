class CreateStreamTags < ActiveRecord::Migration
  def self.up
    create_table :stream_tags do |t|
      t.integer "stream_id"
      t.integer "tag_id"
      t.timestamps
    end
  end

  def self.down
    drop_table :stream_tags
  end
end
