class ChangeStreamIdType < ActiveRecord::Migration
  def self.up
    change_column :streams, :stream_id, :string
  end

  def self.down
    change_column :streams, :stream_id, :integer
  end
end
