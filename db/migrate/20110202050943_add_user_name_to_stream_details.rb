class AddUserNameToStreamDetails < ActiveRecord::Migration
  def self.up
    add_column :stream_details, :user_name, :string
  end

  def self.down
    remove_column :stream_details, :user_name
  end
end
