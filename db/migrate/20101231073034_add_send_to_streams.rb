class AddSendToStreams < ActiveRecord::Migration
   def self.up
    add_column :streams, :send_to, :string
  end

  def self.down
    remove_column :streams, :send_to
  end
end
