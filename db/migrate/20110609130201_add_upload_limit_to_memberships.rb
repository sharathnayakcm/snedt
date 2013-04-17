class AddUploadLimitToMemberships < ActiveRecord::Migration
  def self.up
    add_column :memberships, :upload_limit, :integer
  end

  def self.down
    remove_column :memberships, :upload_limit
  end
end
