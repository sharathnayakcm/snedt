class AddTopicIdToStreams < ActiveRecord::Migration
  def self.up
    add_column :streams, :topic_id, :integer
  end

  def self.down
    remove_column :streams, :topic_id
  end
end
