class AddDeletedAtToCompany < ActiveRecord::Migration
  def self.up
    add_column :companies,:deleted_at,:timestamp
  end

  def self.down
  end
end
