class CreateThankYous < ActiveRecord::Migration
  def self.up
    create_table :thank_yous do |t|
      t.integer :user_id
      t.integer :stream_id

      t.timestamps
    end
  end

  def self.down
    drop_table :thank_yous
  end
end
