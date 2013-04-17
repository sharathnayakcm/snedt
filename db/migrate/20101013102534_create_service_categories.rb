class CreateServiceCategories < ActiveRecord::Migration
  def self.up
    create_table :service_categories do |t|
      t.string :name
      t.timestamps
    end
    add_column :services, :service_category_id, :integer
  end

  def self.down
    drop_table :service_categories
    remove_column :services, :service_category_id
  end
end
