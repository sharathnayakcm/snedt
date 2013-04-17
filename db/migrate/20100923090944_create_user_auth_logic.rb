class CreateUserAuthLogic < ActiveRecord::Migration
  def self.up
    drop_table :users
    create_table :users do |t|
      t.string    :user_name
      t.string    :email,               :null => false                # optional, you can use login instead, or both
      t.string    :crypted_password,    :null => false                # optional, see below
      t.string    :password_salt,       :null => false                # optional, but highly recommended
      t.string    :persistence_token,   :null => false                # required
      t.string    :perishable_token,    :null => false                # optional, see Authlogic::Session::Perishability
      t.string :avatar_file_name
      t.string :avatar_content_type
      t.integer :avatar_file_size
      t.datetime :deleted_at
      t.datetime :last_login
      t.boolean :active, :default => true
      t.timestamps
    end

    def self.down
    end
  end
end