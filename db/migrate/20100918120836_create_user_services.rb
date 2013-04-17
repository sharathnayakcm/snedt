class CreateUserServices < ActiveRecord::Migration
  def self.up
    create_table :user_services do |t|
      t.integer :service_id
      t.integer :user_id
      t.string :profile_name
      t.string :user_name
      t.string :password
      t.string :url
      t.timestamps
    end
  end

  def self.down
    drop_table :user_services
  end
end
