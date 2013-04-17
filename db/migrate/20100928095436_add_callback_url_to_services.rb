class AddCallbackUrlToServices < ActiveRecord::Migration
  def self.up
    add_column :services, :callback_url, :string
  end

  def self.down
    remove_column :services, :callback_url
  end
end
