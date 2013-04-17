class AddUserServiceIdToStreams < ActiveRecord::Migration
  def self.up
      add_column :streams, :user_service_id, :integer
  end

  def self.down
    remove_column :streams, :user_service_id
  end
end
