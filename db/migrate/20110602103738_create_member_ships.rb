class CreateMemberShips < ActiveRecord::Migration
  def self.up
    create_table :memberships do |t|
      t.string :name
      t.text :description
      t.integer :amount
      t.string :membership_type
      t.boolean :active
      t.timestamps
    end
  end

  def self.down
    drop_table :memberships
  end
end
