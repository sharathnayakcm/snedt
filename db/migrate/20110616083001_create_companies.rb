class CreateCompanies < ActiveRecord::Migration
  def self.up
    create_table :companies do |t|
      t.string   :name
      t.string   :url
      t.string   :description
      t.string   :country
      t.integer  :membership_id
      t.boolean  :active
      t.timestamps
    end
  end

  def self.down
    drop_table :companies
  end
end
