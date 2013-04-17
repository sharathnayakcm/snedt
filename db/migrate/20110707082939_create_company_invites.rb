class CreateCompanyInvites < ActiveRecord::Migration
  def self.up
    create_table :company_invites do |t|
      t.integer  "brand_id"
      t.string   "email_id"
      t.integer  "role_id"
      t.boolean  "deactivated"
      t.timestamps
    end
  end

  def self.down
    drop_table :company_invites
  end
end
