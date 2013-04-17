class AddBrandIdToDefaultStreamActions < ActiveRecord::Migration
  def self.up
    add_column :default_stream_actions,:brand_id,:integer
  end

  def self.down
  end
end
