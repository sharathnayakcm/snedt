class AddColumnsToPaymentsTable < ActiveRecord::Migration
  def self.up
    add_column :payments, :membership_id, :integer
    add_column :payments, :company_id, :integer
  end

  def self.down
    remove_column :payments, :company_id
    remove_column :payments, :membership_id
  end
end
