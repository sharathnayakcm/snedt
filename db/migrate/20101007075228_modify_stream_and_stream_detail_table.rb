class ModifyStreamAndStreamDetailTable < ActiveRecord::Migration
  def self.up
    add_column :streams, :sender_id, :integer
    add_column :streams, :receiver_id, :integer
    remove_column :stream_details, :sender_id
    remove_column :stream_details, :receiver_id
  end

  def self.down
    add_column :stream_details, :sender_id, :integer
    add_column :stream_details, :receiver_id, :integer
    remove_column :streams, :sender_id
    remove_column :streams, :receiver_id
  end
end
