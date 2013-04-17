class AddUserServiceIdToDefaultStreamActions < ActiveRecord::Migration
  def self.up
    add_column :default_stream_actions, :user_service_id, :integer
  end

  def self.down
    remove_column :default_stream_actions, :user_service_id
  end
end
