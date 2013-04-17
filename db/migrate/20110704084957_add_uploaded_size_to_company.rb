class AddUploadedSizeToCompany < ActiveRecord::Migration
  def self.up
    add_column :companies,:uploaded_size,:integer,:default=> 0
  end

  def self.down
  end
end
