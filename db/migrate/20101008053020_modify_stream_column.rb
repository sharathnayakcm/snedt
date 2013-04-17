class ModifyStreamColumn < ActiveRecord::Migration
  def self.up
    remove_column :stream_details, :streamable_id
    add_column :stream_details, :stream_id, :integer

  end

  def self.down
    add_column :stream_details, :streamable_id, :integer
    remove_column :stream_details, :stream_id
  end
end
