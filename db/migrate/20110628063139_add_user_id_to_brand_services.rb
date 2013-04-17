class AddUserIdToBrandServices < ActiveRecord::Migration
  def self.up
    add_column :brand_services,:user_id,:integer 
  end

  def self.down
  end
end
