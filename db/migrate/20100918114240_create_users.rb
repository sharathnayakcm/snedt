class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string   :email, :null => false
      t.string   :salted_password
      t.string   :salt
      t.datetime :deleted_at
      t.datetime :last_login
      t.boolean :active, :default => true
      t.timestamps
    end

  end

  def self.down
    drop_table :users
  end
end
