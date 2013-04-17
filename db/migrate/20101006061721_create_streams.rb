class CreateStreams < ActiveRecord::Migration
  def self.up
    create_table :streams do |t|

      t.integer :service_id
      t.integer :user_id
      t.integer :stream_id
      t.integer :message_type_id
      t.text :text
      t.boolean :is_sender_following
      t.boolean :is_receiver_following
      t.timestamps
    end
  end

  def self.down
    drop_table :streams
  end
end
