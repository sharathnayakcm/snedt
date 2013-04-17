class AddCompanyIdToAssets < ActiveRecord::Migration
  def self.up
    add_column :assets,:company_id,:integer
  end

  def self.down
  end
end
