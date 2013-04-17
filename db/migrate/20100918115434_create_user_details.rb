class CreateUserDetails < ActiveRecord::Migration
  def self.up
    create_table :user_details do |t|
      t.integer "user_id"
      t.string  "first_name"
      t.string  "last_name"
      t.string  "address"
      t.string  "city"
      t.string  "state"
      t.string  "zip"
      t.string  "alternate_email"
      t.string  "phone_number"
      t.string  "mobile_number"
      t.string  "country"
      t.text    "about_me"
      t.text    "education"
      t.integer "availability"
      t.string  "time_zone"
      t.timestamps
    end
  end

  def self.down
    drop_table :user_details
  end
end
