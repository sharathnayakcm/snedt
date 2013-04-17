class AddTopicIdToActivities < ActiveRecord::Migration
  def self.up
    add_column :activities, :topic_id, :integer
  end

  def self.down
    remove_column :activities, :topic_id
  end
end