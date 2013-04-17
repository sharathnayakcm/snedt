class AddMembershipIdAndPaymentDateToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :membership_id, :integer
    add_column :users, :next_payment_date, :datetime
  end

  def self.down
    remove_column :users, :membership_id
    remove_column :users, :next_payment_date
  end
end
