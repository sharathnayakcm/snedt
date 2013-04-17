class CompanyPrivacies < ActiveRecord::Migration
  def self.up
    create_table :company_privacies do |t|
      t.integer   :company_id
      t.integer   :visible_to
      t.timestamps
    end
  end

  def self.down
    drop_table :company_privacies
  end
end
