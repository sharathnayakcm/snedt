class CreateDowngrades < ActiveRecord::Migration
  def self.up
    create_table :downgrades do |t|
      t.integer :user_id
      t.datetime :next_payment_date
      t.timestamps
    end
  end

  def self.down
    drop_table :downgrades
  end
end
