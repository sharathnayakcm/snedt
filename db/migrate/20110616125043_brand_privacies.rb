class BrandPrivacies < ActiveRecord::Migration
  def self.up
    create_table :brand_privacies do |t|
      t.integer   :brand_id
      t.integer   :company_id
      t.integer   :visible_to
      t.timestamps
    end
  end

  def self.down
    drop_table :brand_privacies
  end
end
