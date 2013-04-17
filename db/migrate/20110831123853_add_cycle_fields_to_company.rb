class AddCycleFieldsToCompany < ActiveRecord::Migration
  def self.up
    add_column :companies, :next_payment_date, :datetime
    add_column :companies, :cycle_start_date, :datetime
  end

  def self.down
    remove_column :companies, :next_payment_date
    remove_column :companies, :cycle_start_date
  end
end
