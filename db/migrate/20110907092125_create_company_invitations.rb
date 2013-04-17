class CreateCompanyInvitations < ActiveRecord::Migration
  def self.up
    create_table :company_invitations do |t|
      t.integer  :company_id
      t.integer  :brand_id
      t.integer  :access_type
      t.string   :invitee_email_address
      t.boolean  :is_assigned ,:default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :company_invitations
  end
end
